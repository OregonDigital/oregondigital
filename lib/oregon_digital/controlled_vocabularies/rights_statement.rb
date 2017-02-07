module OregonDigital::ControlledVocabularies
  class RightsStatement < ActiveFedora::Rdf::Resource
    include OregonDigital::RDF::Controlled

    configure :rdf_label => RDF::DC11.title

    use_vocabulary :rights
    use_vocabulary :cclicenses
    use_vocabulary :ccpublic

  end
end
