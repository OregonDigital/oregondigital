module OregonDigital::ControlledVocabularies
  class People < ActiveFedora::Rdf::Resource
    include OregonDigital::RDF::Controlled

    use_vocabulary :people

  end
end
