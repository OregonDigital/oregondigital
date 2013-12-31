RDF_VOCABS = {
  :dcmitype             =>  { :prefix => 'http://purl.org/dc/dcmitype/', :source => 'http://dublincore.org/2012/06/14/dctype.rdf' },
  :marcrel              =>  { :prefix => 'http://id.loc.gov/vocabulary/relators/', :source => 'http://id.loc.gov/vocabulary/relators.nt' },
  # :dwc      =>  { :prefix => 'http://rs.tdwg.org/dwc/terms/', :source => 'http://rs.tdwg.org/dwc/rdf/dwcterms.rdf' },
  :iso_639_2            =>  { :prefix => 'http://id.loc.gov/vocabulary/iso639-2/', :source => 'http://id.loc.gov/vocabulary/iso639-2.nt' },
  :premis               =>  { :prefix => 'http://www.loc.gov/premis/rdf/v1#', :source => 'http://www.loc.gov/premis/rdf/v1.nt' },
  :geonames             =>  { :prefix => 'http://sws.geonames.org/', :strict => false, :fetch => false },
  :lcsh                 =>  { :prefix => 'http://id.loc.gov/authorities/subjects/', :strict => false, :fetch => false },
  :aat                  =>  { :prefix => 'http://vocab.getty.edu/aat/', :strict => false, :fetch => false },
  :cclicenses           =>  { :prefix => 'http://creativecommons.org/licenses/', :source => 'https://raw.github.com/OregonDigital/opaque_ns/master/cclicenses/cclicenses.nt'},
  :ccpublic             =>  { :prefix => 'http://creativecommons.org/publicdomain/', :source => 'https://raw.github.com/OregonDigital/opaque_ns/master/cclicenses/cclicenses.nt'},
  :rights               =>  { :prefix => 'http://opaquenamespace.org/rights/', :source => 'https://raw.github.com/OregonDigital/opaque_ns/master/rights.jsonld', :strict => false },
  :mimetype             =>  { :prefix => 'http://purl.org/NET/mediatypes/', :source => 'http://mediatypes.appspot.com/dump.rdf' },
  :oregondigital        =>  { :prefix => 'http://opaquenamespace.org/ns/', :source => 'https://raw.github.com/OregonDigital/opaque_ns/master/opaquenamespace.jsonld', :strict => false }
}
