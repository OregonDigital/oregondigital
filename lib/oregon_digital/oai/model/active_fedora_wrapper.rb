class OregonDigital::OAI::Model::ActiveFedoraWrapper < ::OAI::Provider::Model
  attr_accessor :inner_model

  def initialize(model)
    self.inner_model = model
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
    set = GenericCollection.find(:pid => options[:set]).first
    if options.delete(:set)
      return [] unless set
      model = set.members
    end
    model ||= inner_model
    query = form_query(options)
    result = model.where(ActiveFedora::SolrService.solr_name(:reviewed, :symbol) => "true").where(query)
    result = result.where("id:#{RSolr.escape(selector)}") unless selector.blank? || selector == :all
    result = result.order("#{updated_at_field} desc")
    return result.to_a
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
