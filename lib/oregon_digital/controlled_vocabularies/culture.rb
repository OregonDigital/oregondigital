module OregonDigital::ControlledVocabularies
  class Culture < ActiveFedora::Rdf::Resource
    include OregonDigital::RDF::Controlled

    use_vocabulary :culture
    use_vocabulary :lcsh
    use_vocabulary :lcnames
    use_vocabulary :aat

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
  end
end
