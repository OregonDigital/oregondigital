module OregonDigital::ControlledVocabularies
  class RightsStatement < OregonDigital::RDF::RdfResource
    include OregonDigital::RDF::Controlled

    use_vocabulary :od_rights_statements
    use_vocabulary :cclicenses
    use_vocabulary :ccpublic

  end
end
