class OregonDigital::OAI::Model::SolrInstanceDecorator < Draper::Decorator

    delegate_all
    attr_accessor :modified_date, :identifier, :sets

    #override fields that return uris to return labels
    def set_attrs (key, val)
      self.instance_variable_set("@#{key}", val)
      self.class.send(:define_method, key, proc {self.instance_variable_get("@#{key}")})
    end

    def earliestDate
      string = descMetadata.earliestDate.first || ""
      if descMetadata.latestDate.nil? || descMetadata.latestDate.empty?
        return ""
      end
      string = string + "-" + descMetadata.latestDate.first
      string
    end

    def rights
      if !descMetadata.rights.nil? && !descMetadata.rights.empty?
        descMetadata.rights.first.rdf_subject.to_s
      end
    end

    def accessURL
      return "http://oregondigital.org/catalog/" + descMetadata.pid
    end

    def format
      if !descMetadata.format.empty?
        url = descMetadata.format.first.rdf_subject.to_s
        urlparts = url.split("/")
        num = urlparts.count
        urlparts[num-2] + "/" + urlparts[num-1]
      end
    end

    def location
      if !descMetadata.location.empty?
        format_geonames(descMetadata.location)
      end
    end

    def rangerDistrict
      if !descMetadata.rangerDistrict.empty?
        format_geonames(descMetadata.rangerDistrict)
      end
    end

    def waterBasin
      if !descMetadata.waterBasin.empty?
        format_geonames(descMetadata.waterBasin)
      end
    end

    #since load_instance_from_solr converts string url to rdf resource
    #force result to be a string
    def findingAid
      if !descMetadata.findingAid.empty?
        handle_string_urls(descMetadata.findingAid)
      end
    end

    def hasVersion
      if !descMetadata.hasVersion.empty?
        handle_string_urls(descMetadata.hasVersion)
      end
    end

  private

  def format_geonames (items)
    results = []
    items.each do |item|
      next unless item.respond_to? :rdf_label
      results << item.rdf_label.first.gsub(" >> ", ", ")
    end
    results
  end

  def handle_string_urls (items)
    results = []
    items.each do |item|
      if item.respond_to? :rdf_subject
        results << item.rdf_subject.to_s
      else
        results << item
      end
    end
    results
  end

end
