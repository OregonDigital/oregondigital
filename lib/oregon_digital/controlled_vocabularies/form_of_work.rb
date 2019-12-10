module OregonDigital::ControlledVocabularies
  class FormOfWork < ActiveFedora::Rdf::Resource
    include OregonDigital::RDF::Controlled

    use_vocabulary :aat
    use_vocabulary :lcsh

  end
end
