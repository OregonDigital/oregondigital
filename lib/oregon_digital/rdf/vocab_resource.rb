module OregonDigital::RDF
  class VocabResource < ActiveFedora::Rdf::Resource
    configure :repository => :vocabs
  end
end
