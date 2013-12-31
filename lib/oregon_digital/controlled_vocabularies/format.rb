module OregonDigital::ControlledVocabularies
  class Format < OregonDigital::RDF::RdfResource
    include OregonDigital::RDF::Controlled

    use_vocabulary :mimetype

  end
end
