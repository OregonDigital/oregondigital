module OregonDigital::ControlledVocabularies
  class WorkType < ActiveFedora::Rdf::Resource
    include OregonDigital::RDF::Controlled

    use_vocabulary :worktype

  end
end
