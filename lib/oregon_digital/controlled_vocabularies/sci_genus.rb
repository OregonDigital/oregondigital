module OregonDigital::ControlledVocabularies
  class SciGenus < ActiveFedora::Rdf::Resource
    include OregonDigital::RDF::Controlled

    use_vocabulary :scigenus
    use_vocabulary :ubio
    use_vocabulary :itis

  end
end
