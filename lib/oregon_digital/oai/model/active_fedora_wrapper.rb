class OregonDigital::OAI::Model::ActiveFedoraWrapper < ::OAI::Provider::Model
  include OregonDigital::OAI::Concern::ClassMethods
  attr_accessor :inner_model

  def initialize(model, options={})
    self.inner_model = model
    @limit = options.delete(:limit)
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
   afresults = []
   query_pairs = build_query(selector, options)
   if options[:resumption_token]
     start = OAI::Provider::ResumptionToken.parse(options[:resumption_token]).last
   else start = 0
   end
   query_args = {:sort => "system_modified_dtsi desc", :fl => "id,system_modified_dtsi", :rows=>1000, :start=>start}
   solr_count = ActiveFedora::SolrService.query(query_pairs, query_args)
   qry_total = ActiveFedora::SolrService.count(query_pairs, query_args)
   solr_count = remove_chaff(solr_count,start, qry_total)
   return next_set(solr_count, options[:resumption_token], qry_total) if options[:resumption_token]
   #possibly a partial even if results < limit if a lot of children were removed, so check
   if @limit && (solr_count.count > @limit || solr_count.last['rank'] != qry_total)
     return partial_result(solr_count, OAI::Provider::ResumptionToken.new(options.merge({:last => 0})))
   end
   afresults = convert(solr_count)
   if !selector.blank? && selector!= :all
     return afresults.first
   end
   return afresults.to_a
  end

  def next_set(result, token_string, numFound)
    raise OAI::ResumptionTokenException.new unless @limit
    token = OAI::Provider::ResumptionToken.parse(token_string)
    if @limit >= result.count && result.last['rank'] == numFound
        afresults = convert(result)
        return afresults.to_a
    else
      return partial_result(result, token)
    end
  end

  def partial_result(result, token)
    raise OAI::ResumptionTokenException.new unless result
    part = result.slice(0, @limit)
    offset = part.last['rank'] + 1
    afresults = convert(part)
    OAI::Provider::PartialResult.new(afresults.to_a, token.next(offset))
  end

  def timestamp_field
    return 'modified_date'
  end

  def sets
    cols = []
    result = ActiveFedora::SolrService.query("active_fedora_model_ssi:GenericCollection AND #{ActiveFedora::SolrService.solr_name(:reviewed, :symbol)}:true", :sort=>"id desc", :fl=> "id", :rows=>10000)
    result.each do |col|
      test = ActiveFedora::SolrService.query("desc_metadata__primarySet_ssi: #{RSolr.escape('http://oregondigital.org/resource/'+ col['id'])}", :rows=>1)
      if !test.empty?
        cols << get_set(col["id"])
      end
    end
    cols
  end

  private

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
    query_pairs += (" AND " + add_from_to(options))
    #query_pairs += " AND #{ActiveFedora::SolrService.solr_name(:reviewed, :symbol)}:true"
  end


def extract_labels(qry, field)
  val = qry.first["desc_metadata__#{field}_label_ssm"]
  label_arr = []
  unless val.nil?
    val.each do |term|
      label = term.split('$')
      label_arr << label[0]
    end
  end
  label_arr
end

  def remove_chaff(items,start, numFound)
    afresults = []
    return afresults if numFound == 0
    rank = start
    items.each do |item|
      include_item = true
      item["rank"] = rank
      pseudo = ActiveFedora::Base.load_instance_from_solr(item["id"])
      #can add more tests here if necessary
      #remove children
      if pseudo.compounded?
        include_item = false
      end
      #check primarySet is not corrupt
      if (!pseudo.descMetadata.primarySet.empty?) && (!pseudo.descMetadata.primarySet.first.respond_to? :id)
        include_item = false
      end
      if include_item
        afresults << item
      end
      rank = rank + 1
    end
    #mark end of set in case last record was a child and removed.
    if rank == numFound
      afresults.last['rank'] = numFound
    end
    afresults
  end

  def convert(items)
    afresults = []

    items.each do |item|
      solrqry = ActiveFedora::SolrService.query("id:#{RSolr.escape(item['id'])}")
      next unless is_valid(solrqry)
      pseudo_obj = ActiveFedora::Base.load_instance_from_solr(item["id"])
      wrapped = OregonDigital::OAI::Model::SolrInstanceDecorator.new(pseudo_obj)
      #replace the uris with labels
      uri_fields.each do |field|
        label_arr = extract_labels(solrqry, field)
        wrapped.set_attrs("#{field}", label_arr)
      end
      if solrqry.first["workflow_metadata__destroyed_ssm"]
        wrapped.set_attrs("deleted", true) # put this in the decorator to begin with?
      end
      wrapped.modified_date = Time.parse(item["system_modified_dtsi"]).utc
      sets = []
      if !pseudo_obj.set.nil?
        pseudo_obj.set.each do |setid|
          sets << get_set(setid.to_str.split('/').last)
        end
        wrapped.sets = sets
      end
      afresults << wrapped
    end
    afresults
  end

  def create_description(col)
    solrqry = ActiveFedora::SolrService.query("id:#{RSolr.escape(col.id)}")
    description = "Title: " + col.title
    label_arr = extract_labels(solrqry, "institution")
    if !label_arr.empty?
      institutions = label_arr.inject{|collector,element| collector + ", " + element}
      description += ", Institution(s): " + institutions
    end
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
      set = ::OAI::Set.new(:name => "unknown", :spec=> "oregondigital:unknown", :description => "unknown")
    end
  end

    def is_valid(solrqry)
      if solrqry.first["reviewed_ssim"].first =="true"
        return true
      elsif !solrqry.first["workflow_metadata__destroyed_ssm"].nil? && solrqry.first["workflow_metadata__destroyed_ssm"].first == "true"
        return true
      else return false
      end
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
