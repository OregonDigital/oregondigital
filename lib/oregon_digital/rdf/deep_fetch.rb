module OregonDigital::RDF
  module DeepFetch
    extend ActiveSupport::Concern
    def fetch_external
      controlled_properties.each do |property|
        get_values(property).each do |value|
          resource = value.respond_to?(:resource) ? value.resource : value
          old_label = resource.rdf_label
          fetch_value(resource) if resource.kind_of? ActiveFedora::Rdf::Resource
          resource.persist! unless value.kind_of?(ActiveFedora::Base)
          fix_fedora_index(property, resource)
        end
      end
    end

    def fix_fedora_index(property, resource)
      # Get assets which have this property set, but don't have the right label.
      if resource.rdf_label.first.blank?
        assets = ActiveFedora::Base.where("#{Solrizer.solr_name(apply_prefix(property), :facetable)}:#{RSolr.escape(resource.rdf_subject.to_s)} AND #{Solrizer.solr_name(apply_prefix("#{property}_label"), :facetable)}:[\"\" TO *]")
      else
        assets = ActiveFedora::Base.where(Solrizer.solr_name(apply_prefix(property), :facetable) => resource.rdf_subject.to_s, "-#{Solrizer.solr_name(apply_prefix("#{property}_label"), :facetable)}" => resource.rdf_label.first.to_s).to_a
      end
      assets.each do |a|
        a.skip_queue = 1 if a.respond_to?(:skip_queue=)
        a.update_index
      end
    end

    protected

    def value_changed?(value, old_label)
      value.rdf_label.first.to_s != value.rdf_subject.to_s && old_label != value.rdf_label
    end

    def controlled_properties
      @controlled_properties ||= self.class.properties.each_with_object([]) do |(key, value), arr|
        if value["class_name"] && (value["class_name"] < ActiveFedora::Rdf::Resource || value["class_name"].new.resource.class < ActiveFedora::Rdf::Resource)
          arr << key
        end
      end
    end

    def fetch_value(value)
      redis_connection.cache("fetch-cache:#{value.rdf_subject.to_s}", 7.days) do
        value.fetch
        Time.current.to_s
      end
    end

    def redis_connection
      @redis ||= Redis.new
    end
  end
end
