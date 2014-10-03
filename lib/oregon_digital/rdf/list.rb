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

    def << (value)
      if value.kind_of?(ActiveFedora::Base)
        raise "Unable to append unsaved asset" if !value.persisted?
        compound_resource = OregonDigital::RDF::CompoundResource.new(RDF::Node.new, resource)
        compound_resource.references << value
        value = compound_resource
        value.persist!
      end
      value = value.resource if value.respond_to?(:resource)
      raise "Unable to append unsaved asset" if value.respond_to?(:persisted?) && !value.persisted? && !value.kind_of?(OregonDigital::RDF::CompoundResource)
      result = super
      resource.persist!
      return result
    end
    class ListResource < ActiveFedora::Rdf::List::ListResource
      def solrize
        query([nil, RDF::DC.references, nil]).map{|x| x.object.to_s}
      end

      def fetch
      end
    end
  end
end

