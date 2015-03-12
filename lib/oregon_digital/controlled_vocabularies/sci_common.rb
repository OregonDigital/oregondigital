module OregonDigital::ControlledVocabularies
  class SciCommon < ActiveFedora::Rdf::Resource
    include OregonDigital::RDF::Controlled

    use_vocabulary :scicommon
    use_vocabulary :ubio
    use_vocabulary :itis

  end
end
