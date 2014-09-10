module OregonDigital::ControlledVocabularies
  class SciCommon < ActiveFedora::Rdf::Resource
    include OregonDigital::RDF::Controlled

    use_vocabulary :scicommon

  end
end
