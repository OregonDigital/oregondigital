class OregonDigital::OAI::QualifiedDublinCore < OAI::Provider::Metadata::Format

    include OregonDigital::OAI::Concern::ClassMethods

    def initialize
      @prefix = 'oai_qdc'
      @schema = 'http://dublincore.org/schemas/xmls/qdc/2008/02/11/qualifieddc.xsd'
      @namespace = 'http://purl.org/dc/terms/'
      @element_namespace = 'dcterms'

      # Dublin Core Terms Fields
      @fields = [:title, :description, :identifier, :date, :created, :issued,
                 :creator, :contributor, :subject, :type, :rights, :spatial, :language, :isPartOf]
      # Format causing problems with Rails reserved keywords  :format
    end

    def header_specification
      {
        'xmlns:oai_dc' => "http://www.openarchives.org/OAI/2.0/oai_dc/",
        'xmlns:oai_qdc' => "http://worldcat.org/xmlschemas/qdc-1.0/",
        'xmlns:dc' => "http://purl.org/dc/elements/1.1/",
        'xmlns:dcterms' => "http://purl.org/dc/terms/",
        'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
        'xsi:schemaLocation' =>
          %{http://www.openarchives.org/OAI/2.0/oai_dc/
            http://www.openarchives.org/OAI/2.0/oai_dc.xsd}.gsub(/\s+/, ' ')
      }
    end


    # For each Dublin Core field, oai_qdc_map returns values, this gets called to grab values
    def value_for(field, record, map)
      method = map[field] ? map[field] : field

      val = []

      method.each do |fld|
        if record.respond_to?(fld) && !record.send(fld).nil?
          val << record.send(fld) unless record.send(fld).empty?
        end
      end

      if val.is_a?(String) && !val.nil?
        return val
      elsif val.is_a?(Array)
        return val.join('; ')
      else
        return val ||= []
      end

    end
end
