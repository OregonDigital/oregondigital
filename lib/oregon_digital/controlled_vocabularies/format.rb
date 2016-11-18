module OregonDigital::ControlledVocabularies
  class Format < ActiveFedora::Rdf::Resource
    include OregonDigital::RDF::Controlled

    use_vocabulary :mediatype
    use_vocabulary :mimetype

    # Custom fetch method for SPAR Ontologies Mediatype URIs
    # to bypass HTTP redirects and go straight to RDF/XML file
    def fetch
      if self.rdf_subject.to_s.include?('spar')
        uri = self.rdf_subject.to_s
        xml_url = uri.sub 'https://w3id.org/spar/', 'http://www.sparontologies.net/'
        xml_url.concat('.rdf')

        response = RestClient.get xml_url, {accept: :xml}
        xmldoc = Nokogiri::XML(response)
        new_label = xmldoc.at_xpath("/rdf:RDF/rdf:Description/rdfs:label/text()")

        self << RDF::Statement.new(rdf_subject, RDF::SKOS.prefLabel, new_label)

        persist!
      else
        super
      end
    end
  end
end
