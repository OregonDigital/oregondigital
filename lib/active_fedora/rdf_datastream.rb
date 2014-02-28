module ActiveFedora
  class RDFDatastream < ActiveFedora::Datastream
    include Solrizer::Common
    include ActiveFedora::Rdf::NestedAttributes
    include Rdf::Indexing
    extend Rdf::Properties

    delegate :rdf_subject, :set_value, :get_values, :attributes=, :to => :resource

    class << self
      def rdf_subject &block
        if block_given?
          return @subject_block = block
        end

        @subject_block ||= lambda { |ds| ds.pid }
      end
    end

    before_save do
      if content.blank?
        logger.warn "Cowardly refusing to save a datastream with empty content: #{self.inspect}"
        false
      end
    end

    def metadata?
      true
    end
    
    def content
      serialize
    end

    def content=(content)
      resource.clear!
      resource << RDF::Reader.for(serialization_format).new(content)
      content
    end

    def content_changed?
      return false unless instance_variable_defined? :@resource
      @content = serialize
      super
    end

    def freeze
      @resource.freeze
    end

    # Utility method which can be overridden to determine the object
    # resource that is created.
    def resource_class
      Rdf::ObjectResource
    end

    ##
    # The resource is the RdfResource object that stores the graph for
    # the datastream and is the central point for its relationship to
    # other nodes.
    #
    # set_value, get_value, and property accessors are delegated to this object.
    def resource
      @resource ||= begin
                      r = resource_class.new(digital_object ? self.class.rdf_subject.call(self) : nil)
                      r.singleton_class.properties = self.class.properties
                      r.singleton_class.properties.keys.each do |property|
                        r.singleton_class.send(:register_property, property)
                      end
                      r.datastream = self
                      r.singleton_class.accepts_nested_attributes_for(*nested_attributes_options.keys) unless nested_attributes_options.blank?
                      r << RDF::Reader.for(serialization_format).new(datastream_content) if datastream_content
                      r
                    end
    end

    alias_method :graph, :resource

    ##
    # This method allows for delegation.
    # This patches the fact that there's no consistent API for allowing delegation - we're matching the
    # OMDatastream implementation as our "consistency" point.
    # @TODO: We may need to enable deep RDF delegation at one point.
    def term_values(*values)
      self.send(values.first)
    end

    def update_indexed_attributes(hash)
      hash.each do |fields, value|
        fields.each do |field|
          self.send("#{field}=", value)
        end
      end
    end

    def serialize
      resource.set_subject!(pid) if (digital_object or pid) and rdf_subject.node?
      resource.dump serialization_format
    end

    def deserialize(data=nil)
      return RDF::Graph.new if new? && data.nil?
      data ||= datastream_content
      data.force_encoding('utf-8')
      RDF::Graph.new << RDF::Reader.for(serialization_format).new(data)
    end

    def serialization_format
      raise "you must override the `serialization_format' method in a subclass"
    end

  end
end
