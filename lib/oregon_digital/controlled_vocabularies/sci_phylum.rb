module OregonDigital::ControlledVocabularies
  class SciPhylum < ActiveFedora::Rdf::Resource
    include OregonDigital::RDF::Controlled

    use_vocabulary :sciphylum

  end
end
