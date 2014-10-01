module OregonDigital::ControlledVocabularies
  class Culture < ActiveFedora::Rdf::Resource
    include OregonDigital::RDF::Controlled
    configure :base_uri => "http://opaquenamespace.org/ns/culture/"

    use_vocabulary :culture
    use_vocabulary :lcsh
    use_vocabulary :lcnames

  end
end
