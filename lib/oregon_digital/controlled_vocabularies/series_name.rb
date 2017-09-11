module OregonDigital::ControlledVocabularies
  class SeriesName < ActiveFedora::Rdf::Resource
    include OregonDigital::RDF::Controlled

    use_vocabulary :seriesname

  end
end
