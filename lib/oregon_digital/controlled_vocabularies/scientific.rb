require 'rest_client'

module OregonDigital::ControlledVocabularies
  class Scientific < ActiveFedora::Rdf::Resource
    include OregonDigital::RDF::Controlled

    use_vocabulary :sciphylum
    use_vocabulary :sciclass
    use_vocabulary :scigenus
    use_vocabulary :scicommon
    use_vocabulary :ubio
    use_vocabulary :itis

    # Custom fetch methods for ITIS.gov and uBio authority URLs
    def fetch
      if self.rdf_subject.to_s.include?('itis.gov')
        fetch_itis
      elsif self.rdf_subject.to_s.include?('ubio.org')
        fetch_ubio
      else
        super
      end
    end
  end
end
