module OregonDigital::ControlledVocabularies
  class SciGenus < ActiveFedora::Rdf::Resource
    include OregonDigital::RDF::Controlled

    use_vocabulary :scigenus

  end
end
