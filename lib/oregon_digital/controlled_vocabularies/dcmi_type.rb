module OregonDigital::ControlledVocabularies
  class DCMIType < OregonDigital::RDF::RdfResource
    include OregonDigital::RDF::Controlled

    use_vocabulary :dcmitype

  end
end
