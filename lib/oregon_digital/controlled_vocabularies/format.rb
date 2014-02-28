module OregonDigital::ControlledVocabularies
  class Format < ActiveFedora::Rdf::Resource
    include OregonDigital::RDF::Controlled

    use_vocabulary :mimetype

  end
end
