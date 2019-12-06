module OregonDigital::ControlledVocabularies
  class AccessRestrictions < ActiveFedora::Rdf::Resource
    include OregonDigital::RDF::Controlled

    use_vocabulary :accessrestrict

  end
end

