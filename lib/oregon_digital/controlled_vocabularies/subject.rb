module OregonDigital::ControlledVocabularies
  class Subject < ActiveFedora::Rdf::Resource
    include OregonDigital::RDF::Controlled

    # metadata librarians want multiple authoritative sources with dct.subject
    use_vocabulary :lcsh
    use_vocabulary :lcnames
    use_vocabulary :tgm
    use_vocabulary :aat
    use_vocabulary :subject
    use_vocabulary :lc_orgs
    use_vocabulary :creator
    use_vocabulary :people
    use_vocabulary :itis
    use_vocabulary :ubio
    use_vocabulary :osubuildings
    use_vocabulary :wikidata
    use_vocabulary :ulan
    use_vocabulary :lcgenreforms
    use_vocabulary :osuacademicunits

    # Call custom fetch methods for ITIS or uBio URLs.
    # Make wikidata entity URIs usable to fetch.
    # Our gems don't handle their https redirect, and JSON is the default response which we have errors parsing, so force to NT.
    # For fetch purposes only, change URI from http://www.wikidata.org/entity/Q5343795 to https://www.wikidata.org/wiki/Special:EntityData/Q5343795.nt
    def fetch
      # Call custom fetch methods for ITIS.gov and uBio authority URLs
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

    class QaLcsh < Qa::Authorities::Loc
      include OregonDigital::Qa::Caching
      def search(q, sub_authority=nil)
        super(q, 'subjects')
      end

      def loc_response_to_qa(data)
        response = super(data)
        for link in data.links
          response["id"] = link[1] if link[0].nil?
        end
        return response
      end
    end

    @qa_interface = QaLcsh.new
  end
end
