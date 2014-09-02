module OregonDigital::ControlledVocabularies
  class GettyTGN < ActiveFedora::Rdf::Resource
    include OregonDigital::RDF::Controlled
    use_vocabulary :getty_tgn
  end
end
