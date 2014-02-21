# This file generated automatically using vocab-fetch from https://raw.github.com/OregonDigital/opaque_ns/master/opaquenamespace.jsonld
require 'rdf'
module OregonDigital::Vocabularies
  class OREGONDIGITAL < ::RDF::Vocabulary("http://opaquenamespace.org/ns/")

    # Property definitions
    property :contributingInstitution, :label => 'Contributing Institution', :comment =>
      %(A reference to the institutions or administrative units that
        contributed to the creation, management, description, and/or
        dissemination of the digital resource. For example, one
        institution may physically hold the original resource, another
        may perform the digital imaging, and another may create
        metadata.)
    property :set, :label => 'set', :comment =>
      %(Defines a relationship between an object and a group or
        collection of objects to which it belongs.)

    # Other terms
  end
end
