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
        return descMetadata.rights.first.rdf_label.first + ", " + descMetadata.rights.first.rdf_subject.to_s
      end
    end

    def accessURL
      return "http://oregondigital.org/catalog/" + descMetadata.pid
    end

end
