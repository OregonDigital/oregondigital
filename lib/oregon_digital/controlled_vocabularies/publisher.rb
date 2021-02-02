module OregonDigital::ControlledVocabularies
  class Publisher < ActiveFedora::Rdf::Resource
    include OregonDigital::RDF::Controlled

    use_vocabulary :lcnames
    use_vocabulary :ulan
    use_vocabulary :publisher
    use_vocabulary :creator
    use_vocabulary :wikidata
    use_vocabulary :osuacademicunits

    # Make wikidata entity URIs usable to fetch.
    # Our gems don't handle their https redirect, and JSON is the default response which we have errors parsing, so force to NT.
    # For fetch purposes only, change URI from http://www.wikidata.org/entity/Q5343795 to https://www.wikidata.org/wiki/Special:EntityData/Q5343795.nt
    def fetch
      if self.rdf_subject.to_s.include?('wikidata') then
        self.rdf_subject.to_s.gsub!('http://www.wikidata.org/entity/', 'https://www.wikidata.org/wiki/Special:EntityData/')
        self.rdf_subject.to_s.concat('.nt')
      elsif self.rdf_subject.to_s.include?('loc.gov') then
        self.rdf_subject.to_s.gsub!('http', 'https')
      end

      super

      if self.rdf_subject.to_s.include?('wikidata') then
        self.rdf_subject.to_s.gsub!('https://www.wikidata.org/wiki/Special:EntityData/', 'http://www.wikidata.org/entity/')
        self.rdf_subject.to_s.gsub!('.nt', '')
      elsif self.rdf_subject.to_s.include?('loc.gov') then
        self.rdf_subject.to_s.gsub!('https', 'http')
      end
    end
  end
end
