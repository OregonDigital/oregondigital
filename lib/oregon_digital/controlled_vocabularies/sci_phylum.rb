module OregonDigital::ControlledVocabularies
  class SciPhylum < ActiveFedora::Rdf::Resource
    include OregonDigital::RDF::Controlled

    use_vocabulary :sciphylum
    use_vocabulary :ubio
    use_vocabulary :itis

  end
end
