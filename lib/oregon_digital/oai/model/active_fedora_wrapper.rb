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
   query_args = {:sort => "system_modified_dtsi desc", :fl => "id,system_modified_dtsi", :rows=>1000000}
   solr_count = ActiveFedora::SolrService.query(query_pairs, query_args)
   return next_set(solr_count, options[:resumption_token]) if options[:resumption_token]
   if @limit && solr_count.count > @limit
     return partial_result(solr_count, OAI::Provider::ResumptionToken.new(options.merge({:last => 0})))
   end
   afresults = convert(solr_count)
   if !selector.blank? && selector!= :all
     return afresults.first
   end
   return afresults.to_a
  end

  def next_set(result, token_string)
    raise OAI::ResumptionTokenException.new unless @limit
    token = OAI::Provider::ResumptionToken.parse(token_string)
    if token.last+@limit == result.count
      part = result.slice(token.last, @limit)
      afresults = convert(part)
      return afresults.to_a
    else
      return partial_result(result, token)
    end
  end

  def partial_result(result, token)
    raise OAI::ResumptionTokenException.new unless result
    offset = token.last+@limit
    part = result.slice(token.last, @limit)
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
      cols << get_set(col["id"])
    end
    cols
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
  private

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

  def convert(items)
    afresults = []
    items.each do |item|
      solrqry = ActiveFedora::SolrService.query("id:#{RSolr.escape(item['id'])}")
      next unless is_valid(solrqry)
      pseudo_obj = ActiveFedora::Base.load_instance_from_solr(item["id"])
      wrapped = OregonDigital::OAI::Model::SolrInstanceDecorator.new(pseudo_obj)
      #replace the uris with labels
      uri_fields.each do |field|
        val = solrqry.first["desc_metadata__#{field}_label_ssm"]
        unless val.nil?
          label_arr = []
          val.each do |term|
            label = term.split('$')
            label_arr << label[0]
          end
          final_field = mapped_fields[field] || field
          wrapped.set_attrs("#{final_field}", label_arr)
        end
      end
      if solrqry.first["workflow_metadata__destroyed_ssm"]
        wrapped.set_attrs("deleted", true) # put this in the decorator to begin with?
      end
      #override the item identifier
      wrapped.identifier = "http://oregondigital.org/catalog/" + item["id"]
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

  def get_set(id)
    col = ActiveFedora::Base.load_instance_from_solr(id)
    set = ::OAI::Set.new(:name => col.title, :spec=> col.id, :description => col.description)
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
