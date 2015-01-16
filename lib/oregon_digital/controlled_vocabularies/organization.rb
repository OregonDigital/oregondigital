module OregonDigital::ControlledVocabularies
  class Organization < ActiveFedora::Rdf::Resource
    include OregonDigital::RDF::Controlled
    use_vocabulary :oregon_universities
    use_vocabulary :institutions
    configure :rdf_label => RDF::SKOS.hiddenLabel

    property :label, :predicate => RDF::RDFS.label
  end
end
