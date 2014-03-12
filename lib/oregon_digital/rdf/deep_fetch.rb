module OregonDigital::RDF
  module DeepFetch
    def fetch_external
      controlled_properties = self.class.properties.each_with_object([]) do |(key, value), arr|
        if value["class_name"] && value["class_name"] < ActiveFedora::Rdf::Resource
          arr << key
        end
      end
      redis = Redis.new
      controlled_properties.each do |property|
        values = get_values(property)
        values.each do |value|
          if value.kind_of?(ActiveFedora::Rdf::Resource)
            old_label = value.rdf_label
            redis.cache("fetch-cache:#{value.rdf_subject.to_s}", 7.days) do
              value.fetch
              Time.current.to_s
            end
            if value.rdf_label.first != value.rdf_subject && old_label != value.rdf_label
              value.persist!
              fix_fedora_index(property, value)
            end
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
  end
end
