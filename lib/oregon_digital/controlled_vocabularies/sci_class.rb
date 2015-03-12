module OregonDigital::ControlledVocabularies
  class SciClass < ActiveFedora::Rdf::Resource
    include OregonDigital::RDF::Controlled

    use_vocabulary :sciclass
    use_vocabulary :ubio
    use_vocabulary :itis

  end
end
