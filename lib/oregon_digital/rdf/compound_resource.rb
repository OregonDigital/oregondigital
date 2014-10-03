module OregonDigital::RDF
  class CompoundResource < ActiveFedora::Rdf::Resource
    configure :type => RDF::URI("http://opaquenamespace.org/ns/compoundObject")
    property :references, :predicate => RDF::DC.references, :class_name => ::GenericAsset
    property :title, :predicate => RDF::DC.title
    delegate :pid, :to => :first_reference, :allow_nil => true

    alias_method :orig_title, :title

    def title
      return reference_title if reference_title.present? && orig_title.blank?
      orig_title
    end

    def first_reference
      references.first
    end
    
    private


    def reference_title
      Array.wrap(first_reference.title) if first_reference.respond_to?(:title)
    end
  end
end
