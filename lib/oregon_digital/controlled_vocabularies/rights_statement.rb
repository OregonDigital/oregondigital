module OregonDigital::ControlledVocabularies
  class RightsStatement < ActiveFedora::Rdf::Resource
    include OregonDigital::RDF::Controlled

    use_vocabulary :rights
    use_vocabulary :cclicenses
    use_vocabulary :ccpublic

  end
end
