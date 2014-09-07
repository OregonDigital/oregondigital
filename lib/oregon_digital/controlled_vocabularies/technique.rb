module OregonDigital::ControlledVocabularies
  class Technique < ActiveFedora::Rdf::Resource
    include OregonDigital::RDF::Controlled

    use_vocabulary :technique
    use_vocabulary :aat

  end
end
