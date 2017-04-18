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
   return nil unless qry_total > 0
   results = get_results_from_query(query_pairs, query_args, qry_total)
   return nil unless !results[:items].blank?
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
      solr_doc = ActiveFedora::Base.find_with_conditions({:id=>item["id"]}).first
      wrapped = build_wrapped(pseudo_obj, solr_doc)

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

  def build_wrapped(pseudo_obj, solr_doc)
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
      if !solr_doc["desc_metadata__#{field}_label_ssm"].blank?
        solr_doc["desc_metadata__#{field}_label_ssm"].each do |val|
          label = val.split("$").first
          if !label.include? "http"
            label_arr << label
          end
        end
      end
      wrapped.set_attrs("#{field}", label_arr)
    end
    #check if soft_delete
    if solr_doc["workflow_metadata__destroyed_ssim"] == ["true"]
      wrapped.set_attrs("deleted", true)
    end
    #add modified_date
    wrapped.modified_date = Time.parse(solr_doc["system_modified_dtsi"]).utc

    wrapped
  end

  def create_description(solr_doc)
    description = ""
    description += "Title: " + solr_doc["desc_metadata__title_ssm"].first unless solr_doc["desc_metadata__title_ssm"].blank?

    label_arr = []
    if !solr_doc["desc_metadata__institution_label_ssm"].blank?
      solr_doc["desc_metadata__institution_label_ssm"].each do |inst|
        label_arr << inst.split("$").first
      end

      if !label_arr.empty?
        institutions = label_arr.join(", ")
        description += ", Institution(s): " + institutions
      end
    end
    description
  end

  def get_set(id)
    begin
      solr_doc = ActiveFedora::Base.find_with_conditions({:id=>id}).first
      if !solr_doc["desc_metadata__description_ssm"].blank?
        description = solr_doc["desc_metadata__description_ssm"].first
      else
        description = create_description(solr_doc)
      end
      set = ::OAI::Set.new(:name => solr_doc["desc_metadata__title_ssm"].first, :spec=> id, :description => description)
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
