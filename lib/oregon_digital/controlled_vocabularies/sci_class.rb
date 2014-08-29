module OregonDigital::ControlledVocabularies
  class SciClass < ActiveFedora::Rdf::Resource
    include OregonDigital::RDF::Controlled

    use_vocabulary :sciclass

  end
end
