module OregonDigital::ControlledVocabularies
  class LocalCollection < ActiveFedora::Rdf::Resource
    include OregonDigital::RDF::Controlled

    use_vocabulary :localcoll

  end
end
