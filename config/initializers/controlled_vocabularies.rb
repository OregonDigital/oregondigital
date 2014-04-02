RDF_VOCABS = {
  :dcmitype             =>  { :prefix => 'http://purl.org/dc/dcmitype/', :source => 'http://dublincore.org/2012/06/14/dctype.rdf' },
  :marcrel              =>  { :prefix => 'http://id.loc.gov/vocabulary/relators/', :source => 'http://id.loc.gov/vocabulary/relators.nt' },
  :dwc                  =>  { :prefix => 'http://rs.tdwg.org/dwc/terms/', :strict => false },
  :iso_639_1            =>  { :prefix => 'http://id.loc.gov/vocabulary/iso639-1/', :source => 'http://id.loc.gov/vocabulary/iso639-1.nt'},
  :iso_639_2            =>  { :prefix => 'http://id.loc.gov/vocabulary/iso639-2/', :source => 'http://id.loc.gov/vocabulary/iso639-2.nt'},
  :marc_lang            =>  { :prefix => 'http://id.loc.gov/vocabulary/languages/', :source => 'http://id.loc.gov/vocabulary/languages.nt'},
  :premis               =>  { :prefix => 'http://www.loc.gov/premis/rdf/v1#', :source => 'http://www.loc.gov/premis/rdf/v1.nt' },
  :geonames             =>  { :prefix => 'http://sws.geonames.org/', :strict => false, :fetch => false },
  :lcsh                 =>  { :prefix => 'http://id.loc.gov/authorities/subjects/', :strict => false, :fetch => false },
  :aat                  =>  { :prefix => 'http://vocab.getty.edu/aat/', :strict => false, :fetch => false },
  :cclicenses           =>  { :prefix => 'http://creativecommons.org/licenses/', :source => 'https://raw.github.com/OregonDigital/opaque_ns/master/cclicenses/cclicenses.nt'},
  :ccpublic             =>  { :prefix => 'http://creativecommons.org/publicdomain/', :source => 'https://raw.github.com/OregonDigital/opaque_ns/master/cclicenses/cclicenses.nt'},
  :rights               =>  { :prefix => 'http://opaquenamespace.org/rights/', :source => 'https://raw.github.com/OregonDigital/opaque_ns/master/rights.jsonld', :strict => true },
  :mimetype             =>  { :prefix => 'http://purl.org/NET/mediatypes/', :source => 'http://mediatypes.appspot.com/dump.rdf' },
  :oregondigital        =>  { :prefix => 'http://opaquenamespace.org/ns/', :source => 'https://raw.github.com/OregonDigital/opaque_ns/master/opaquenamespace.jsonld', :strict => true },
  :oregon_universities  =>  { :prefix => 'http://dbpedia.org/resource/', :source => 'https://raw.github.com/OregonDigital/opaque_ns/master/oregon_universities.jsonld', :strict => true },
  :set                  =>  { :prefix => 'http://oregondigital.org/resource/', :strict => false }
}
