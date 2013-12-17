RDF_VOCABS = {
  :dcmitype             =>  { :prefix => 'http://purl.org/dc/dcmitype/', :source => 'http://dublincore.org/2012/06/14/dctype.rdf' },
  :marcrel              =>  { :prefix => 'http://id.loc.gov/vocabulary/relators/', :source => 'http://id.loc.gov/vocabulary/relators.nt' },
  # :dwc      =>  { :prefix => 'http://rs.tdwg.org/dwc/terms/', :source => 'http://rs.tdwg.org/dwc/rdf/dwcterms.rdf' },
  :iso_639_2            =>  { :prefix => 'http://id.loc.gov/vocabulary/iso639-2/', :source => 'http://id.loc.gov/vocabulary/iso639-2.nt' },
  :premis               =>  { :prefix => 'http://www.loc.gov/premis/rdf/v1#', :source => 'http://www.loc.gov/premis/rdf/v1.nt' },
  :geonames             =>  { :prefix => 'http://sws.geonames.org/', :strict => false, :fetch => false },
  :oregondigital        =>  { :prefix => 'http://opaquenamespace.org/', :strict => false, :fetch => false },
  :cclicenses           =>  { :prefix => 'http://creativecommons.org/licenses/by/4.0/', :strict => false, :fetch => false},
  :od_rights_statements =>  { :prefix => 'http://opaquenamespace.org/rights/', :source => 'https://raw.github.com/OregonDigital/opaque_ns/master/rights.jsonld' },
}
