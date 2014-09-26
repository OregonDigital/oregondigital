module OregonDigital::ControlledVocabularies
  class Organization < ActiveFedora::Rdf::Resource
    include OregonDigital::RDF::Controlled
    use_vocabulary :institutions

    property :label, :predicate => RDF::RDFS.label
  end
end
