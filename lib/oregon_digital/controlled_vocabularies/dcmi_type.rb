module OregonDigital::ControlledVocabularies
  class DCMIType < ActiveFedora::Rdf::Resource
    include OregonDigital::RDF::Controlled

    use_vocabulary :dcmitype

  end
end
