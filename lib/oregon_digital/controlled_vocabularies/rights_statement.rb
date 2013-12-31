module OregonDigital::ControlledVocabularies
  class RightsStatement < OregonDigital::RDF::RdfResource
    include OregonDigital::RDF::Controlled

    use_vocabulary :rights
    use_vocabulary :cclicenses
    use_vocabulary :ccpublic

  end
end
