require 'rest_client'

module OregonDigital::ControlledVocabularies
  class Geographic < ActiveFedora::Rdf::Resource
    include OregonDigital::RDF::Controlled

    configure :rdf_label => RDF::URI('http://www.geonames.org/ontology#name')
    use_vocabulary :geonames

    class QaGeonames < OregonDigital::RDF::Controlled::ClassMethods::QaRDF
      GEONAMES_PREFIX   = 'http://sws.geonames.org/'
      GEONAMES_API_USER = 'johnson.tom@gmail.com'

      def search(q, sub_authority = nil)
        q = URI.escape(q)
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
        return json_response.collect {|geo| geo_json_to_qa_item(geo)}
      end

      def geo_json_to_qa_item(geo)
        item = { id: GEONAMES_PREFIX + geo['geonameId'].to_s }
        item[:label] = geo["toponymName"]
        unless geo["countryName"].blank?
          if geo["adminName1"].blank?
            item[:label] += " (%s)" % geo["countryName"]
          else
            item[:label] += " (%s >> %s)" % [geo["countryName"], geo["adminName1"]]
          end
        end

        return item
      end
    end

    @qa_interface = QaGeonames.new

  end
end
