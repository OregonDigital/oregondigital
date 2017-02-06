# This file generated automatically using vocab-fetch from https://raw.github.com/OregonDigital/opaque_ns/master/rights.jsonld
require 'rdf'
module OregonDigital::Vocabularies
  class RIGHTS < ::RDF::StrictVocabulary("http://opaquenamespace.org/ns/rights/")

    # Other terms
    property :educational, :label => 'Educational Use Permitted'
    property :"orphan-work-us", :label => 'Orphan Work'
    property :"rr-f", :label => 'Rights Reserved - Free Access'
    property :"rr-r", :label => 'Rights Reserved - Restricted Access'
    property :"unknown", :label => 'Unknown'
  end
end
