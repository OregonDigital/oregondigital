class OregonDigital::OAI::Model::SolrInstanceDecorator < Draper::Decorator

    delegate_all
    attr_accessor :modified_date, :identifier, :sets

    #override fields that return uris to return labels
    def set_attrs (key, val)
      self.instance_variable_set("@#{key}", val)
      self.class.send(:define_method, key, proc {self.instance_variable_get("@#{key}")})
    end

    def earliestDate
      if !solr_doc["desc_metadata__earliestDate_ssm"].blank? && !solr_doc["desc_metadata__latestDate_ssm"].blank?
        solr_doc["desc_metadata__earliestDate_ssm"].first + "-" +  solr_doc["desc_metadata__latestDate_ssm"].first
      end
    end

    def rights
      if !solr_doc["desc_metadata__rights_ssm"].blank?
        solr_doc["desc_metadata__rights_ssm"]
      end
    end

    #return the uri, for use in the provider
    def primarySet
      solr_doc["desc_metadata__primarySet_ssm"].first
    end

    def accessURL
      return "http://oregondigital.org/catalog/" + id
    end

    def format
      if !solr_doc["desc_metadata__format_ssm"].blank?
        format = solr_doc["desc_metadata__format_ssm"].first
        urlparts = format.split("/")
        num = urlparts.count
        urlparts[num-2] + "/" + urlparts[num-1]
      end
    end

    def location
      if !solr_doc["desc_metadata__location_label_ssm"].blank?
        format_geonames(solr_doc["desc_metadata__location_label_ssm"])
      end
    end

    def rangerDistrict
      if !solr_doc["desc_metadata__rangerDistrict_label_ssm"].blank?
        format_geonames(solr_doc["desc_metadata__rangerDistrict_label_ssm"])
      end
    end

    def waterBasin
      if !solr_doc["desc_metadata__waterBasin_ssm"].blank?
        format_geonames(solr_doc["desc_metadata__waterBasin_ssm"])
      end
    end

    #since load_instance_from_solr converts string url to rdf resource
    #force result to be a string
    def findingAid
      solr_doc["desc_metadata__findingAid_ssm"]
    end

    def hasVersion
      solr_doc["desc_metadata__hasVersion_ssm"]
    end

  private
  def solr_doc
    @solr_doc ||= ActiveFedora::Base.find_with_conditions({:id=>id}).first
  end

  def format_geonames (items)
    results = []
    items.each do |item|
      label = item.split("$").first
      results << label.gsub(" >> ", ", ")
    end
    results
  end


end
