require 'rest_client'

module OregonDigital::ControlledVocabularies
  class Geographic < ActiveFedora::Rdf::Resource
    include OregonDigital::RDF::Controlled

    configure :rdf_label => RDF::URI('http://www.geonames.org/ontology#name')
    use_vocabulary :geonames

    property :name, :predicate => RDF::URI('http://www.geonames.org/ontology#name')
    property :latitude, :predicate => RDF::URI('http://www.w3.org/2003/01/geo/wgs84_pos#lat')
    property :longitude, :predicate => RDF::URI('http://www.w3.org/2003/01/geo/wgs84_pos#long')
    property :parentFeature, :predicate => RDF::URI('http://www.geonames.org/ontology#parentFeature'), :class_name => 'OregonDigital::ControlledVocabularies::Geographic'
    property :parentCountry, :predicate => RDF::URI('http://www.geonames.org/ontology#parentCountry'), :class_name => 'OregonDigital::ControlledVocabularies::Geographic'
    property :featureCode, :predicate => RDF::URI('http://www.geonames.org/ontology#featureCode')
    property :featureClass, :predicate => RDF::URI('http://www.geonames.org/ontology#featureClass')
    property :population, :predicate => RDF::URI('http://www.geonames.org/ontology#population')
    property :countryCode, :predicate => RDF::URI('http://www.geonames.org/ontology#countryCode')
    property :wikipedia, :predicate => RDF::URI('http://www.geonames.org/ontology#wikipediaArticle')

    ##
    # Overrides rdf_label to recursively add location disambiguation when available.
    def rdf_label
      label = super
      unless parentFeature.empty? or RDF::URI(label.first).valid?
        #TODO: Identify more featureCodes that should cause us to terminate the sequence
        return label if top_level_element? 

        parent_label = (parentFeature.first.kind_of? ActiveFedora::Rdf::Resource) ? parentFeature.first.rdf_label.first : []
        return label if parent_label.empty? or RDF::URI(parent_label).valid? or parent_label.starts_with? '_:'
        label = "#{label.first} >> #{parent_label}" 
      end
      Array(label)
    end

    # Fetch parent features if they exist. Necessary for automatic population of rdf label.
    def fetch
      result = super
      return result if top_level_element?
      parentFeature.each do |feature|
        feature.fetch
      end
      result
    end

    # Persist parent features.
    def persist!
      result = super
      return result if top_level_element?
      parentFeature.each do |feature|
        feature.persist!
      end
      result
    end

    def top_level_element?
      featureCode = self.featureCode.first
      top_level_codes = [RDF::URI('http://www.geonames.org/ontology#A.PCLI')]
      featureCode.respond_to?(:rdf_subject) && top_level_codes.include?(featureCode.rdf_subject)
    end

    class QaGeonames < OregonDigital::RDF::Controlled::ClassMethods::QaRDF

      def search(q, sub_authority = nil)
        q = URI.escape(q)
        uri = "http://api.geonames.org/searchJSON?q=#{q}&maxRows=20&username=#{APP_CONFIG['geonames']['username']}"
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
        item = { id: APP_CONFIG['geonames']['prefix'] + geo['geonameId'].to_s }
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
