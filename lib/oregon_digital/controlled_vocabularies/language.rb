module OregonDigital::ControlledVocabularies
  class Language < ActiveFedora::Rdf::Resource
    include OregonDigital::RDF::Controlled

    use_vocabulary :iso_639_1
    use_vocabulary :iso_639_2
  end
end
