class OregonDigital::OAI::DublinCore < OAI::Provider::Metadata::Format

    include OregonDigital::OAI::Concern::ClassMethods

    def initialize
      @prefix = 'oai_dc'
      @schema = 'http://www.openarchives.org/OAI/2.0/oai_dc.xsd'
      @namespace = 'http://www.openarchives.org/OAI/2.0/oai_dc/'
      @element_namespace = 'dc'
      @fields = []
      tempfields = string_fields + uri_fields
      tempfields.each do |field|
        tempfield = mapped_fields[field] || field
        @fields << tempfield.to_sym
      end
    end

    def header_specification
      {
        'xmlns:oai_dc' => "http://www.openarchives.org/OAI/2.0/oai_dc/",
        'xmlns:dc' => "http://purl.org/dc/elements/1.1/",
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
