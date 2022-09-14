require 'rest_client'

module OregonDigital::ControlledVocabularies
  class Scientific < ActiveFedora::Rdf::Resource
    include OregonDigital::RDF::Controlled

    use_vocabulary :sciphylum
    use_vocabulary :sciclass
    use_vocabulary :scigenus
    use_vocabulary :scispecies
    use_vocabulary :scicommon
    use_vocabulary :ubio
    use_vocabulary :itis
    use_vocabulary :wikidata
    use_vocabulary :lcsh

    # Custom fetch methods for ITIS.gov and uBio authority URLs
    # Make wikidata entity URIs usable to fetch.
    # Our gems don't handle their https redirect, and JSON is the default response which we have errors parsing, so force to NT.
    # For fetch purposes only, change URI from http://www.wikidata.org/entity/Q5343795 to https://www.wikidata.org/wiki/Special:EntityData/Q5343795.nt
    def fetch
      if self.rdf_subject.to_s.include?('itis.gov')
        fetch_itis
      elsif self.rdf_subject.to_s.include?('ubio.org')
        fetch_ubio
      else
        if self.rdf_subject.to_s.include?('wikidata') then
          self.rdf_subject.to_s.gsub!('http://www.wikidata.org/entity/', 'https://www.wikidata.org/wiki/Special:EntityData/')
          self.rdf_subject.to_s.concat('.nt')
        end

        super

        if self.rdf_subject.to_s.include?('wikidata') then
          self.rdf_subject.to_s.gsub!('https://www.wikidata.org/wiki/Special:EntityData/', 'http://www.wikidata.org/entity/')
          self.rdf_subject.to_s.gsub!('.nt', '')
        end
      end
    end
  end
end
