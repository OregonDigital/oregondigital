class OregonDigital::OAI::QualifiedDublinCore < OAI::Provider::Metadata::Format

    include OregonDigital::OAI::Concern::ClassMethods

    def initialize
      @prefix = 'oai_qdc'
      @schema = 'http://dublincore.org/schemas/xmls/qdc/2008/02/11/qualifieddc.xsd'
      @namespace = 'http://purl.org/dc/terms/'
      @element_namespace = 'dcterms'

      # Dublin Core Terms Fields
      # For new fields, add here first then add to oai_qdc_map
      @fields = [:title, :alternative, :description, :abstract, :identifier, :date, :created, :issued,
                  :creator, :contributor, :subject, :type, :rights, :rightsHolder, :license, :publisher, :provenance,
                  :spatial, :language, :isPartOf, :tableOfContents, :temporal, :bibliographicCitation, :relation,
                  :isReferencedBy, :hasPart, :hasVersion, :isVersionOf, :extent]
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

    # For each Dublin Core field, oai_qdc_map returns properties, this gets called to grab values
    def value_for(field, record, map)
      method = map[field] ? map[field] : field

      val = []

      method.each do |fld|
        if record.respond_to?(fld) && !record.send(fld).nil?
          val << record.send(fld) unless record.send(fld).empty?
        elsif record.descMetadata.respond_to?(fld) && !record.descMetadata.send(fld).nil?
          val << record.descMetadata.send(fld) unless record.descMetadata.send(fld).empty?
        end
      end

      if val.is_a?(String) && !val.nil?
        return val
      elsif val.is_a?(Array) && !val.empty?
        return val.join('; ')
      else
        return nil
      end
    end

    # Copied from ruby-oai gem: ruby-oai/lib/oai/provider/metadata_format.rb
    # Changed to not write out fields if values are nil
    def encode(model, record)
      if record.respond_to?("to_#{prefix}")
        record.send("to_#{prefix}")
      else
        xml = Builder::XmlMarkup.new
        map = model.respond_to?("map_#{prefix}") ? model.send("map_#{prefix}") : {}
          xml.tag!("#{prefix}:#{element_namespace}", header_specification) do
            fields.each do |field|
              values = value_for(field, record, map)
              next if values.nil?
              if values.respond_to?(:each)
                values.each do |value|
                  xml.tag! "#{element_namespace}:#{field}", value
                end
              else
                xml.tag! "#{element_namespace}:#{field}", values
              end
            end
          end
        xml.target!
      end
    end
end
