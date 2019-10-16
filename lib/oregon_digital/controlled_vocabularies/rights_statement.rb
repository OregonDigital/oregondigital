module OregonDigital::ControlledVocabularies
  class RightsStatement < ActiveFedora::Rdf::Resource
    include OregonDigital::RDF::Controlled

    use_vocabulary :rights
    use_vocabulary :cclicenses
    use_vocabulary :ccpublic
    use_vocabulary :rightsstatements

    # Custom fetch method for rightsstatement.org URIs
    # Correct URI is /vocab, but /data is what responds with linked data
    # For fetch purposes only, change URI from http://rightsstatements.org/vocab/InC-EDU/1.0/ to http://rightsstatements.org/data/InC-EDU/1.0.ttl
    def fetch
      if self.rdf_subject.to_s.include?('rightsstatements') then
        self.rdf_subject.to_s.gsub!('vocab', 'data')
        self.rdf_subject.to_s.gsub!(/\/$/, '.ttl')
      end

      super

      if self.rdf_subject.to_s.include?('rightsstatements') then
        self.rdf_subject.to_s.gsub!('data', 'vocab')
        self.rdf_subject.to_s.gsub!('.ttl', '/')
      end
    end
  end
end
