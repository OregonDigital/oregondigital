class OregonDigital::OAI::Model::ActiveFedoraWrapper < ::OAI::Provider::Model
  include OregonDigital::OAI::Concern::ClassMethods
  attr_accessor :inner_model

  def initialize(model, options={})
    self.inner_model = model
    @limit = options.delete(:limit)
    @max_rows = options.delete(:qry_rows) || 1000
    unless options.empty?
      raise ArgumentError.new(
        "Unsupported options [#{options.keys.join(', ')}]"
      )
    end
  end

  def earliest
    query_pairs = "active_fedora_model_ssi:* -active_fedora_model_ssi:GenericCollection"
    query_args = {:sort => "system_modified_dtsi asc", :fl => "id,system_modified_dtsi", :rows => 1}
    earliest = ActiveFedora::SolrService.query(query_pairs, query_args)
    earliest.first["system_modified_dtsi"]
  end

  def latest
    query_pairs = "active_fedora_model_ssi:* -active_fedora_model_ssi:GenericCollection"
    query_args = {:sort => "system_modified_dtsi desc", :fl => "id,system_modified_dtsi", :rows => 1}
    latest = ActiveFedora::SolrService.query(query_pairs, query_args)
    latest.first["system_modified_dtsi"]
  end

  def find(selector, options = {})

   query_pairs = build_query(selector, options)
   start = options[:resumption_token] ? OAI::Provider::ResumptionToken.parse(options[:resumption_token]).last : 0
   query_args = {:sort => "system_modified_dtsi desc", :fl => "id,system_modified_dtsi", :rows=>@max_rows, :start=>start}
   qry_total = ActiveFedora::SolrService.count(query_pairs)
   return [] unless qry_total > 0
   results = get_results_from_query(query_pairs, query_args, qry_total)
   return [] unless !results[:items].blank?
   return next_set(results, options[:resumption_token], qry_total) if options[:resumption_token]

   if @limit && results[:rank] != qry_total - 1
     return partial_result(results, OAI::Provider::ResumptionToken.new(options.merge({:last => 0})))
   end
   if !selector.blank? && selector!= :all
     return results[:items].first
   end
   return results[:items]
  end

  def next_set(results, token_string, numFound)
    raise OAI::ResumptionTokenException.new unless @limit
    token = OAI::Provider::ResumptionToken.parse(token_string)
    if results[:rank] == numFound -1
        return results[:items]
    else
      return partial_result(results, token)
    end
  end

  def partial_result(results, token)
    raise OAI::ResumptionTokenException.new unless results
    offset = results[:rank] + 1
    OAI::Provider::PartialResult.new(results[:items], token.next(offset))
  end

  def timestamp_field
    return 'modified_date'
  end

  def sets
    cols = []
    result = ActiveFedora::SolrService.query("active_fedora_model_ssi:GenericCollection AND #{ActiveFedora::SolrService.solr_name(:reviewed, :symbol)}:true", :sort=>"id desc", :fl=> "id", :rows=>10000)
    result.each do |col|
      test = ActiveFedora::SolrService.query("desc_metadata__primarySet_ssi: #{RSolr.escape('http://oregondigital.org/resource/'+ col['id'])}", :rows=>1)
      obj = get_set(col["id"]) unless test.empty?
      cols << obj unless obj.nil?
    end
    cols
  end

  private

  def get_results_from_query(query_pairs, query_args, qry_total)
   numres = 0
   while numres==0
     solr_results = ActiveFedora::SolrService.query(query_pairs, query_args)
     results = build_results(solr_results, query_args[:start], qry_total)
     numres = results[:items].count
     break unless results[:rank] < qry_total-1
     query_args[:start] = results[:rank] + 1
   end
   results
  end

  def get_set_from_options(options)
    if !options[:resumption_token].nil?
      token = OAI::Provider::ResumptionToken.parse(options[:resumption_token])
      set = token.set
    else
      set = options[:set]
    end
    set
  end

  def build_query(selector, options={})
    query_pairs = []
    set = get_set_from_options(options)
    if set
      query_pairs = "desc_metadata__set_sim: #{RSolr.escape('http://oregondigital.org/resource/' + set)}"
    elsif !selector.blank? && selector!= :all
      query_pairs = "id:#{RSolr.escape(selector)}"
    else
      query_pairs = "active_fedora_model_ssi:* -active_fedora_model_ssi:GenericCollection"
    end
    query_pairs += (" AND (read_access_group_ssim:public OR workflow_metadata__destroyed_ssim:true)")
    query_pairs += (" AND desc_metadata__primarySet_teim:[ * TO * ]")
    query_pairs += (" AND " + add_from_to(options))
  end

  def build_results(items, start, numFound)

    results = {:rank=>0, :items=>[]}
    this_set_counter = 0
    total_set_counter = start #from the resumptionToken
    items.each do |item|
      pseudo_obj = ActiveFedora::Base.load_instance_from_solr(item["id"])

      wrapped = build_wrapped(pseudo_obj, item)
      if !wrapped.nil?
        results[:items] << wrapped
        this_set_counter += 1
      end
      results[:rank] = total_set_counter
      #both counts are zero index.
      break unless this_set_counter < @limit
      total_set_counter += 1
    end
    results
  end

  def build_wrapped(pseudo_obj, item)
    wrapped = OregonDigital::OAI::Model::SolrInstanceDecorator.new(pseudo_obj)
    #add set
    sets = []
    if !pseudo_obj.set.nil?
      pseudo_obj.set.each do |setid|
        set = get_set(setid.to_str.split('/').last)
        return nil unless !set.nil?
        sets << set
      end
      wrapped.sets = sets
    end

    #replace the uris with labels
    uri_fields.each do |field|
      label_arr = []
      pseudo_obj.descMetadata.send("#{field}").each do |val|
        if ((val.respond_to? :rdf_label) && (!val.rdf_label.first.include? "http"))
          label_arr << val.rdf_label.first
        end
      end
      wrapped.set_attrs("#{field}", label_arr)
    end
    #check if soft_delete
    if pseudo_obj.soft_destroyed?
      wrapped.set_attrs("deleted", true)
    end
    #add modified_date
    wrapped.modified_date = Time.parse(item["system_modified_dtsi"]).utc

    wrapped
  end

  def create_description(obj)
    description = "Title: " + obj.title
    if obj.descMetadata.institution.first.respond_to? :rdf_label
      label_arr = obj.descMetadata.institution.first.rdf_label
      if !label_arr.empty?
        institutions = label_arr.inject{|collector,element| collector + ", " + element}
        description += ", Institution(s): " + institutions
      end
    end
    description
  end

  def get_set(id)
    begin
      col = ActiveFedora::Base.load_instance_from_solr(id)
      description = col.description
      if description.nil?
        description = create_description(col)
      end
      set = ::OAI::Set.new(:name => col.title, :spec=> col.id, :description => description)
    rescue
      set = nil
    end
    set
  end

  def add_from_to(options)
    from = options.delete(:from)
    if from
      from = from.to_time(:utc) unless from.is_a? Time
      from = from.iso8601
    else from = '*'
    end
    until_date = options.delete(:until)
    if until_date
      until_date = until_date.to_time(:utc)unless until_date.is_a? Time
      until_date = until_date.iso8601
    else until_date = '*'
    end
    "#{updated_at_field}:[#{from} TO #{until_date}]"
  end

  def created_at_field
    "system_create_dtsi"
  end

  def updated_at_field
    "system_modified_dtsi"
  end

end
