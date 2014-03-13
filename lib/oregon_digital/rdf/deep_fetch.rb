module OregonDigital::RDF
  module DeepFetch
    def fetch_external
      controlled_properties.each do |property|
        get_values(property).each do |value|
          old_label = value.rdf_label
          fetch_value(value) if value.kind_of? ActiveFedora::Rdf::Resource
          if value_changed?(value, old_label)
            value.persist!
            fix_fedora_index(property, value)
          end
        end
      end
    end

    def fix_fedora_index(property, resource)
      # Get assets which have this property set, but don't have the right label.
      assets = GenericAsset.where(Solrizer.solr_name(apply_prefix(property), :facetable) => resource.rdf_subject.to_s, "-#{Solrizer.solr_name(apply_prefix("#{property}_label"), :facetable)}" => resource.rdf_label.first.to_s).to_a
      assets.each do |a|
        a.update_index
      end
    end

    protected

    def value_changed?(value, old_label)
      value.rdf_label.first.to_s != value.rdf_subject.to_s && old_label != value.rdf_label
    end

    def controlled_properties
      @controlled_properties ||= self.class.properties.each_with_object([]) do |(key, value), arr|
        if value["class_name"] && value["class_name"] < ActiveFedora::Rdf::Resource
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
