module OregonDigital::ControlledVocabularies
  class WorkType < ActiveFedora::Rdf::Resource
    include OregonDigital::RDF::Controlled

    use_vocabulary :aat
    use_vocabulary :worktype
    use_vocabulary :lcsh
    use_vocabulary :tgm

  end
end
