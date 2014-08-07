# This file generated automatically using vocab-fetch from http://purl.org/ontology/holding#
require 'rdf'
module OregonDigital::Vocabularies
  class HOLDING < ::RDF::StrictVocabulary("http://purl.org/ontology/holding#")

    # Class definitions
    property :Agent, :label => 'Agent', :comment =>
      %(Use one of bf:Agent or foaf:Agent)
    property :Document, :label => 'Document', :comment =>
      %(Use one of bibo:Document, foaf:Document, bf:Work or
        bf:Instance)
    property :Item, :label => 'Item', :comment =>
      %(Use one of bf:HeldItem frbr:Item rdac:Item)

    # Property definitions
    property :label, :label => 'label', :comment =>
      %(A call number, shelf mark or similar label of an item)
    property :broaderExemplar, :label => 'broader exemplar', :comment =>
      %(Relates a document to an item that contains an exemplar of the
        document as part.)
    property :broaderExemplarOf, :label => 'broader exemplar of', :comment =>
      %(Relates an item to a document which is partly exemplified by
        the item.)
    property :collectedBy, :label => 'collected by', :comment =>
      %(Relates a document and/or item to an agent who collects it.)
    property :collectedBy, :label => 'collected by', :comment =>
      %(Relates an agent to a document and/or item that is collected
        by the agent.)
    property :collectedBy, :label => 'collects', :comment =>
      %(Relates a document and/or item to an agent who collects it.)
    property :collectedBy, :label => 'collects', :comment =>
      %(Relates an agent to a document and/or item that is collected
        by the agent.)
    property :exemplar, :label => 'has exemplar', :comment =>
      %(Relates a document to an item that is an exemplar of the
        document.)
    property :heldBy, :label => 'held by', :comment =>
      %(Relates an item to an agent who holds the item.)
    property :holds, :label => 'holds', :comment =>
      %(Relates an agent to an item which the agent holds.)
    property :exemplarOf, :label => 'is examplar of', :comment =>
      %(Relates an item to the document that is exemplified by the
        item.)
    property :narrowerExemplar, :label => 'narrower exemplar', :comment =>
      %(Relates a document to an item that is an exemplar of a part of
        the document.)
    property :narrowerExemplarOf, :label => 'narrower exemplar of', :comment =>
      %(Relates an item to a document which is partly exemplified by
        the item.)

    # Other terms
  end
end
