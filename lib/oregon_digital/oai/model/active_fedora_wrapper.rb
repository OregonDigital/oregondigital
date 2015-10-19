class OregonDigital::OAI::Model::ActiveFedoraWrapper < ::OAI::Provider::Model
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
    query_pairs = "active_fedora_model_ssi:GenericAsset"
    query_args = {:sort => "system_modified_dtsi asc", :fl => "id,system_modified_dtsi", :rows => 1}
    earliest = ActiveFedora::SolrService.query(query_pairs, query_args)
    earliest.first["system_modified_dtsi"]
  end

  def latest
    query_pairs = "active_fedora_model_ssi:GenericAsset"
    query_args = {:sort => "system_modified_dtsi desc", :fl => "id,system_modified_dtsi", :rows => 1}
    latest = ActiveFedora::SolrService.query(query_pairs, query_args)
    latest.first["system_modified_dtsi"]

  end

  def find(selector, options = {})
   query_pairs = []
   query_args = {}
   afresults = []
   set = options.delete(:set)
   if set
     query_pairs = "desc_metadata__set_sim: #{RSolr.escape('http://oregondigital.org/resource/' + set)}"
   elsif !selector.blank? && selector!= :all
     query_pairs = "id:#{RSolr.escape(selector)}"
   else
     query_pairs = "active_fedora_model_ssi:GenericAsset"
   end
   query_pairs += " AND #{ActiveFedora::SolrService.solr_name(:reviewed, :symbol)}:true"
   query_args = {:sort => "system_modified_dtsi desc", :fl => "id,system_modified_dtsi"}
   solr_count = ActiveFedora::SolrService.query(query_pairs, query_args)
   #binding.pry
   return next_set(solr_count, options[:resumption_token]) if options[:resumption_token]
   if @limit && solr_count.count > @limit
     return partial_result(solr_count, OAI::Provider::ResumptionToken.new(options.merge({:last => 0}))) 
   end
   afresults = convert(solr_count)
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
    result = GenericCollection.where(ActiveFedora::SolrService.solr_name(:reviewed, :symbol) => "true")
    result = result.order("id desc")
    result.map { |col| ::OAI::Set.new(:name => col.title, :spec => col.pid, :description => col.description) }
  end

  private

  def convert(part)
    afresults = []
    part.each do |item|
      #binding.pry
      obj = ActiveFedora::Base.load_instance_from_solr(item["id"])
      obj2 = OregonDigital::OAI::Model::SolrInstanceDecorator.new(obj)
      obj2.modified_date = Time.parse(item["system_modified_dtsi"]).utc
      afresults << obj2
    end
    afresults
  end


    def form_query(options)
      from = options.delete(:from) || '*'
      from = from.iso8601 unless from.to_s == '*'
      until_date = options.delete(:until) || '*'
      until_date = until_date.iso8601 unless until_date.to_s == '*'
      "#{updated_at_field}:[#{from} TO #{until_date}]"
    end

    def created_at_field
      "system_create_dtsi"
    end

    def updated_at_field
      "system_modified_dtsi"
    end

end
