require 'rest_client'

module OregonDigital::ControlledVocabularies
  class Organization < ActiveFedora::Rdf::Resource
    include OregonDigital::RDF::Controlled
    use_vocabulary :oregon_universities
    use_vocabulary :institutions
    use_vocabulary :creator
    use_vocabulary :lcnames

    property :label, :predicate => RDF::RDFS.label

    # Custom fetch methods for dbpedia.org URIs
    # Fetch began failing, due to error with rdf:LangString not having a language, in JSON and n-triples
    # This forces the download of the RDF/XML which doesn't have this issue
    # Also change id.loc.gov URIs to https for fetch to avoid redirect we can't handle
    def fetch
      if self.rdf_subject.to_s.include?('dbpedia') then
        original_uri = self.rdf_subject.to_s
        rdfxml_uri = self.rdf_subject.to_s
        rdfxml_uri = rdfxml_uri.gsub('resource', 'data').concat('.rdf')

        label_xpath = "/rdf:RDF/rdf:Description[@rdf:about='" + original_uri + "']/rdfs:label[@xml:lang='en']/text()"

        response = RestClient.get rdfxml_uri
        xmldoc = Nokogiri::XML(response)
        new_label = xmldoc.at_xpath(label_xpath).to_s

        self << RDF::Statement.new(rdf_subject, RDF::SKOS.prefLabel, new_label) unless new_label.empty?

        persist!
      else
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
end
