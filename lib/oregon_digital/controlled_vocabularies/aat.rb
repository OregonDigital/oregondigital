module OregonDigital::ControlledVocabularies
  class AAT < ActiveFedora::Rdf::Resource
    include OregonDigital::RDF::Controlled
    use_vocabulary :aat

  end
end
