module OregonDigital::RDF
  module DeepFetch
    extend ActiveSupport::Concern
    def fetch_external
      controlled_properties.each do |property|
        get_values(property).each do |value|
          resource = value.respond_to?(:resource) ? value.resource : value
          next unless resource.kind_of?(ActiveFedora::Rdf::Resource)
          old_label = resource.rdf_label.first
          next unless old_label == resource.rdf_subject.to_s || old_label.nil?
          fetch_value(resource) if resource.kind_of? ActiveFedora::Rdf::Resource
          if !value.kind_of?(ActiveFedora::Base) && old_label != resource.rdf_label.first
            resource.persist!
          end
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
        begin
          value.fetch
        rescue
        end
        Time.current.to_s
      end
    end

    def redis_connection
      @redis ||= Redis.new
    end
  end
end
