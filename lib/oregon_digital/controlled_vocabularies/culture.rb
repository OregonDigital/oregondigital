module OregonDigital::ControlledVocabularies
  class Culture < ActiveFedora::Rdf::Resource
    include OregonDigital::RDF::Controlled

    use_vocabulary :culture
    use_vocabulary :lcsh
    use_vocabulary :lcnames

  end
end
