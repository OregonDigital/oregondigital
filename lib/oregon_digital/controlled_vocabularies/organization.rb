module OregonDigital::ControlledVocabularies
  class Organization < OregonDigital::RDF::RdfResource
    include OregonDigital::RDF::Controlled
    use_vocabulary :oregon_universities
    
    property :label, :predicate => RDF::RDFS.label
  end
end
