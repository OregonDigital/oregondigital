module OregonDigital::RDF
  ##
  # Extends RdfResource with support for controlled vocabularies and
  # QuestioningAuthority.
  class VocabularyResource < RdfResource
    configure :repository => :vocabs
  end
end
