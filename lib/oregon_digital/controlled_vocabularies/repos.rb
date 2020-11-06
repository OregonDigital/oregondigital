module OregonDigital::ControlledVocabularies
  class Repos < ActiveFedora::Rdf::Resource
    include OregonDigital::RDF::Controlled

    use_vocabulary :lc_orgs
    use_vocabulary :repository
    use_vocabulary :lcnames
    use_vocabulary :ulan
    use_vocabulary :lcsh

    # Make id.loc.gov URIs work for fetch, our gems don't handle redirect
    # For fetch purposes only, change URI from http to https
    def fetch
      if self.rdf_subject.to_s.include?('loc.gov') then
        self.rdf_subject.to_s.gsub!('http', 'https')
      end

      super

      if self.rdf_subject.to_s.include?('loc.gov') then
        self.rdf_subject.to_s.gsub!('https', 'http')
      end
    end

    class QaLcNames < Qa::Authorities::Loc
      include OregonDigital::Qa::Caching
      def search(q, sub_authority=nil)
        super(q, 'repos')
      end
    end

    @qa_interface = QaLcNames.new

  end
end
