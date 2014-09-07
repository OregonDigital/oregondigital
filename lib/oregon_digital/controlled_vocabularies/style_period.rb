module OregonDigital::ControlledVocabularies
  class StylePeriod < ActiveFedora::Rdf::Resource
    include OregonDigital::RDF::Controlled

    use_vocabulary :styleperiod
    use_vocabulary :aat
    use_vocabulary :lcsh

  end
end
