module OregonDigital::ControlledVocabularies
  class Culture < ActiveFedora::Rdf::Resource
    include OregonDigital::RDF::Controlled

    use_vocabulary :culture

  end
end
