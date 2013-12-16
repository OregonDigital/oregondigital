module OregonDigital::ControlledVocabularies
  class Language < OregonDigital::RDF::RdfResource
    include OregonDigital::RDF::Controlled

    use_vocabulary :iso_639_2

  end
end
