module OregonDigital::RDF
  module DeepFetch
    extend ActiveSupport::Concern
    def fetch_external
      controlled_properties.each do |property|
        get_values(property).each do |value|
          resource = value.respond_to?(:resource) ? value.resource : value
          next unless resource.kind_of?(ActiveFedora::Rdf::Resource)
          fetch_value(resource) if resource.kind_of? ActiveFedora::Rdf::Resource
          resource.persist! unless value.kind_of?(ActiveFedora::Base)
        end
      end
    end

    protected

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
