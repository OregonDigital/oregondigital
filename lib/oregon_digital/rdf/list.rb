module OregonDigital::RDF
  ##
  # Override default List implementation to fix some bugs with appending to a list.
  # TODO: Move this up and analyze the resulting n-triples.
  class List < ActiveFedora::Rdf::List
    class << self
      def from_uri(uri, vals)
        list = ListResource.from_uri(uri, vals)
        self.new(list.rdf_subject, list)
      end
    end
    def initialize(*args)
      super
      @graph = ListResource.new(subject) << graph unless graph.kind_of? ActiveFedora::Rdf::Resource
    end

    def node_from_value(value)
      if value.kind_of?(::RDF::Resource)
        if value.kind_of?(RDF::URI) && value.to_s.include?(Datastream::OregonRDF.resource_class.base_uri) 
          return GenericAsset.from_uri(value, resource).adapt_to_cmodel
        end
      end
      super
    end
    def << (value)
      value = value.resource if value.respond_to?(:resource)
      raise "Unable to append unsaved asset" if value.respond_to?(:persisted?) && !value.persisted?
      result = super
      resource.persist!
      return result
    end
    class ListResource < ActiveFedora::Rdf::List::ListResource
      def solrize
        query([nil, RDF.first, nil]).map{|x| x.object.to_s}
      end

      def fetch
      end
    end
  end
end

