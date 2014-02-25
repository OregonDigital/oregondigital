# This file generated automatically using vocab-fetch from https://raw.github.com/OregonDigital/opaque_ns/master/rights.jsonld
require 'rdf'
module OregonDigital::Vocabularies
  class RIGHTS < ::RDF::StrictVocabulary("http://opaquenamespace.org/rights/")

    # Other terms
    property :allRightsReserved, :label => 'All Rights Reserved'
    property :unknown, :label => 'Copyright Status Unknown'
    property :educationalUse, :label => 'Educational Use Permitted'
    property :publicDomainAcknowledgement, :label => 'Public Domain; Acknowledgement Requested.'
  end
end
