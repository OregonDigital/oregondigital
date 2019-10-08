module OregonDigital::ControlledVocabularies
  class License < ActiveFedora::Rdf::Resource
    include OregonDigital::RDF::Controlled

    configure :rdf_label => RDF::DC11.title

    use_vocabulary :cclicenses
    use_vocabulary :ccpublic
  end
end
