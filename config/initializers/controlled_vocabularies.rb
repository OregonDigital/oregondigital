RDF_VOCABS = {
  :dcmitype             =>  { :prefix => 'http://purl.org/dc/dcmitype/', :source => 'http://dublincore.org/2012/06/14/dctype.rdf' },
  :marcrel              =>  { :prefix => 'http://id.loc.gov/vocabulary/relators/', :source => 'http://id.loc.gov/vocabulary/relators.nt' },
  :dwc                  =>  { :prefix => 'http://rs.tdwg.org/dwc/terms/', :strict => false },
  :iso_639_2            =>  { :prefix => 'http://id.loc.gov/vocabulary/iso639-2/', :source => 'http://id.loc.gov/vocabulary/iso639-2.nt'},
  :premis               =>  { :prefix => 'http://www.loc.gov/premis/rdf/v1#', :source => 'http://www.loc.gov/premis/rdf/v1.nt' },
  :geonames             =>  { :prefix => 'http://sws.geonames.org/', :strict => false, :fetch => false },
  :lcsh                 =>  { :prefix => 'http://id.loc.gov/authorities/subjects/', :strict => false, :fetch => false },
  :lcnames              =>  { :prefix => 'http://id.loc.gov/authorities/names/', :strict => false, :fetch => false },
  :tgm                  =>  { :prefix => 'http://id.loc.gov/vocabulary/graphicMaterials', :strict => false, :fetch => false },
  :afs_ethn             =>  { :prefix => 'http://id.loc.gov/vocabulary/ethnographicTerms', :strict => false, :fetch => false },
  :lc_orgs              =>  { :prefix => 'http://id.loc.gov/vocabulary/organizations', :strict => false, :fetch => false },
  :aat                  =>  { :prefix => 'http://vocab.getty.edu/aat/', :strict => false, :fetch => false },
  :getty_tgn            =>  { :prefix => 'http://vocab.getty.edu/tgn/', :strict => false, :fetch => false },
  :cclicenses           =>  { :prefix => 'http://creativecommons.org/licenses/', :source => 'https://raw.github.com/OregonDigital/opaque_ns/master/cclicenses/cclicenses.nt'},
  :ccpublic             =>  { :prefix => 'http://creativecommons.org/publicdomain/', :source => 'https://raw.github.com/OregonDigital/opaque_ns/master/cclicenses/cclicenses.nt'},
  :uonames              =>  { :prefix => 'http://opaquenamespace.org/ns/uo-names/', :source => 'https://raw.github.com/OregonDigital/opaque_ns/master/uo/names.jsonld', :strict => false, :fetch => false },
  :rights               =>  { :prefix => 'http://opaquenamespace.org/ns/rights/', :source => 'https://raw.github.com/OregonDigital/opaque_ns/master/rights.jsonld', :strict => true },
  :mediatype            =>  { :prefix => 'https://w3id.org/spar/mediatype/', :strict => false, :fetch => false },
  :oregondigital        =>  { :prefix => 'http://opaquenamespace.org/ns/', :source => 'https://raw.github.com/OregonDigital/opaque_ns/master/opaquenamespace.jsonld', :strict => false, :fetch => false },
  :oregon_universities  =>  { :prefix => 'http://dbpedia.org/resource/', :source => 'https://raw.github.com/OregonDigital/opaque_ns/master/oregon_universities.jsonld', :strict => false, :fetch => false },
  :set                  =>  { :prefix => 'http://oregondigital.org/resource/', :strict => false, :fetch => false },
  :holding              =>  { :prefix => 'http://purl.org/ontology/holding#' },
  :creator              =>  { :prefix => 'http://opaquenamespace.org/ns/creator/', :source => 'https://raw.github.com/OregonDigital/opaque_ns/master/creator.jsonld', :strict => false, :fetch => false },
  :culture              =>  { :prefix => 'http://opaquenamespace.org/ns/culture/', :source => 'https://raw.github.com/OregonDigital/opaque_ns/master/culture.jsonld', :strict => false, :fetch => false },
  :localcoll            =>  { :prefix => 'http://opaquenamespace.org/ns/localCollectionName/', :source => 'https://raw.github.com/OregonDigital/opaque_ns/master/localCollectionName.jsonld', :strict => false, :fetch => false },
  :institutions         =>  { :prefix => 'http://opaquenamespace.org/resource/', :source => 'https://raw.github.com/OregonDigital/opaque_ns/master/oregondigital_orgs.jsonld', :strict => false, :fetch => false },
  :people               =>  { :prefix => 'http://opaquenamespace.org/ns/people/', :source => 'https://raw.github.com/OregonDigital/opaque_ns/master/people.jsonld', :strict => false, :fetch => false },
  :repository           =>  { :prefix => 'http://opaquenamespace.org/ns/repository/', :source => 'https://raw.github.com/OregonDigital/opaque_ns/master/repository.jsonld', :strict => false, :fetch => false },
  :sciclass             =>  { :prefix => 'http://opaquenamespace.org/ns/class/', :source => 'https://raw.github.com/OregonDigital/opaque_ns/master/scientific_class.jsonld', :strict => false, :fetch => false },
  :scicommon            =>  { :prefix => 'http://opaquenamespace.org/ns/commonNames/', :source => 'https://raw.github.com/OregonDigital/opaque_ns/master/scientific_commonNames.jsonld', :strict => false, :fetch => false },
  :scigenus             =>  { :prefix => 'http://opaquenamespace.org/ns/genus/', :source => 'https://raw.github.com/OregonDigital/opaque_ns/master/scientific_genus.jsonld', :strict => false, :fetch => false },
  :sciphylum            =>  { :prefix => 'http://opaquenamespace.org/ns/phylum/', :source => 'https://raw.githubusercontent.com/OregonDigital/opaque_ns/master/scientific_phylum.jsonld', :strict => false, :fetch => false },
  :styleperiod          =>  { :prefix => 'http://opaquenamespace.org/ns/stylePeriod/', :source => 'https://raw.github.com/OregonDigital/opaque_ns/master/stylePeriod.jsonld', :strict => false, :fetch => false },
  :subject              =>  { :prefix => 'http://opaquenamespace.org/ns/subject/', :source => 'https://raw.github.com/OregonDigital/opaque_ns/master/subject.jsonld', :strict => false, :fetch => false },
  :technique            =>  { :prefix => 'http://opaquenamespace.org/ns/technique/', :source => 'https://raw.github.com/OregonDigital/opaque_ns/master/technique.jsonld', :strict => false, :fetch => false },
  :worktype             =>  { :prefix => 'http://opaquenamespace.org/ns/workType/', :source => 'https://raw.github.com/OregonDigital/opaque_ns/master/workType.jsonld', :strict => false, :fetch => false },
  :ubio                 =>  { :prefix => 'http://ubio.org/authority/', :strict => false, :fetch => false },
  :itis                 =>  { :prefix => 'https://www.itis.gov/', :strict => false, :fetch => false },
  :bm                   =>  { :prefix => 'http://collection.britishmuseum.org/', :strict => false, :fetch => false },
  :archiveshub          =>  { :prefix => 'http://data.archiveshub.ac.uk/def/', :source => 'http://data.archiveshub.ac.uk/def/' },
  :bibframe             =>  { :prefix => 'http://bibframe.org/vocab/', :source => 'http://bibframe.org/vocab/', :strict => false, :fetch => false},
  :ccrel                =>  { :prefix => 'http://creativecommons.org/ns#', :strict => false, :fetch => false },
  :mods                 =>  { :prefix => 'http://www.loc.gov/standards/mods/modsrdf/v1/#', :strict => false, :fetch => false },
  :exif                 =>  { :prefix => 'http://www.w3.org/2003/12/exif/ns#', :strict => false, :fetch => false},
  :dummycreator                 =>  { :prefix => 'http://dummynamespace.org/creator/', :strict => false, :fetch => false},
  :iana                 =>  { :prefix => "http://www.iana.org/assignments/relation/", :strict => false, :fetch => false},
  :ore                  =>  { :prefix => "http://www.openarchives.org/ore/1.0/datamodel#", :strict => false, :fetch => false},
  :schema               =>  { :prefix => 'https://schema.org', :strict => false, :fetch => false},
  :ulan                 =>  { :prefix => 'http://vocab.getty.edu/ulan/', :strict => false, :fetch => false},
  :osubuildings         =>  { :prefix => 'http://opaquenamespace.org/ns/osuBuildings/', :strict => false, :fetch => false},
  :cdwa                 =>  { :prefix => 'http://opaquenamespace.org/ns/cdwa/', :strict => false, :fetch => false},
  :wikidata             =>  { :prefix => 'http://www.wikidata.org/entity/', :strict => false, :fetch => false},
  :lcgenreforms         =>  { :prefix => 'http://id.loc.gov/authorities/genreForms', :strict => false, :fetch => false },
  :osuacademicunits     =>  { :prefix => 'http://opaquenamespace.org/ns/osuAcademicUnits/', :strict => false, :fetch => false},
  :seriesname           =>  { :prefix => 'http://opaquenamespace.org/ns/seriesName/', :strict => false, :fetch => false},
  :rightsstatements     =>  { :prefix => 'http://rightsstatements.org/vocab/', :strict => false, :fetch => false},
  :accessrestrict       =>  { :prefix => 'http://opaquenamespace.org/ns/accessRestrictions/', :strict => false, :fetch => false},
  :publisher            =>  { :prefix => 'http://opaquenamespace.org/ns/publisher/', :strict => false, :fetch => false},
  :tfddbasins           =>  { :prefix => 'http://opaquenamespace.org/ns/TFDDbasins/', :strict => false, :fetch => false}
}
