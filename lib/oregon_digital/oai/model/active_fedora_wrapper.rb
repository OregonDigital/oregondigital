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
    earliest = inner_model.order("#{updated_at_field} asc").limit(1).first
    earliest.try(:modified_date) || Time.at(0).utc.iso8601
  end

  def latest
    latest = inner_model.order("#{updated_at_field} desc").limit(1).first
    latest.try(:modified_date) || Time.at(0).utc.iso8601
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
     query_pairs = "active_fedora_model_ssi:#{self.inner_model}"
   end
   query_pairs += " AND #{ActiveFedora::SolrService.solr_name(:reviewed, :symbol)}:true"
   query_args = {:sort => "system_modified_dtsi desc", :fl => "id"}
   solr_count = ActiveFedora::SolrService.query(query_pairs, query_args)
   #binding.pry
   return next_set(solr_count, options[:resumption_token]) if options[:resumption_token]
   if @limit && solr_count.count > @limit
     return partial_result(solr_count, OAI::Provider::ResumptionToken.new(options.merge({:last => 0}))) 
   end
    solr_count.map{|x| x["id"]}.each do |pid|
      afresults << ActiveFedora::Base.load_instance_from_solr(pid)
    end
   return afresults.to_a

  end

  def next_set(result, token_string)
    #binding.pry
    raise OAI::ResumptionTokenException.new unless @limit
    token = OAI::Provider::ResumptionToken.parse(token_string)
    if token.last+@limit == result.count
      part = result.slice(token.last, @limit)
      afresults = []
      part.map{|x| x["id"]}.each do |pid|
        afresults << ActiveFedora::Base.load_instance_from_solr(pid)
      end
      return afresults.to_a
    else
      return partial_result(result, token)
    end
  end

  def partial_result(result, token)
    #binding.pry
    raise OAI::ResumptionTokenException.new unless result
    offset = token.last+@limit
    part = result.slice(token.last, @limit)
    afresults = []
    part.map{|x| x["id"]}.each do |pid|
      afresults << ActiveFedora::Base.load_instance_from_solr(pid)
    end
    OAI::Provider::PartialResult.new(afresults.to_a, token.next(offset))

  end

  def timestamp_field
    :parsed_modified_date
  end

  def sets
    result = GenericCollection.where(ActiveFedora::SolrService.solr_name(:reviewed, :symbol) => "true")
    result = result.order("id desc")
    result.map { |col| ::OAI::Set.new(:name => col.title, :spec => col.pid, :description => col.description) }
  end

  private

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
