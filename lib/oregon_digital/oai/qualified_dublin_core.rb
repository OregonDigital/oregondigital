class OregonDigital::OAI::QualifiedDublinCore < OAI::Provider::Metadata::Format

    include OregonDigital::OAI::Concern::ClassMethods

    def initialize
      @prefix = 'oai_qdc'
      @schema = 'http://dublincore.org/schemas/xmls/qdc/2008/02/11/qualifieddc.xsd'
      @namespace = 'http://purl.org/dc/terms/'
      @element_namespace = 'dc'

      @fields = []
      tempfields = uri_fields + string_fields
      tempfields.each do |field|
        tempfield = mapped_fields[field] || field
        @fields << tempfield.to_sym
      end
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

    def value_for(field, record, map)
      begin
        if record.respond_to?(field)
          val = record.send field
        end
      ensure 
        return val ||=[]
      end
    end
end
