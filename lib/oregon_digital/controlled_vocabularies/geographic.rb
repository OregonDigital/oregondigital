require 'rest_client'

module OregonDigital::ControlledVocabularies
  class Geographic < OregonDigital::RDF::RdfResource
    include OregonDigital::RDF::Controlled

    use_vocabulary :geonames

    class QaGeonames < OregonDigital::RDF::Controlled::ClassMethods::QaRDF
      GEONAMES_PREFIX   = 'http://sws.geonames.org/'
      GEONAMES_API_USER = 'johnson.tom@gmail.com'

      def search(q)
        uri = "http://api.geonames.org/searchJSON?q=#{q}&maxRows=20&username=#{GEONAMES_API_USER}"
        json_terms = get_json(uri)["geonames"]
        self.response = build_response(json_terms)
      end

      def results
        return response
      end

      private

      def get_json(url)
        r = RestClient.get url, {accept: :json}
        self.response = JSON.parse(r)
      end

      def build_response(json_response)
        json_response.each do |geo|
          geo['id'] = GEONAMES_PREFIX + geo.delete('geonameId').to_s + '/'
          geo['countryId'] = GEONAMES_PREFIX + geo.delete('countryId').to_s + '/'
        end
        json_response
      end
    end

    @qa_interface = QaGeonames.new

  end
end
