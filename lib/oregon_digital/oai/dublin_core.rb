class OregonDigital::OAI::DublinCore < OAI::Provider::Metadata::Format

  include OregonDigital::OAI::Concern::ClassMethods

  def initialize
    @prefix = 'oai_dc'
    @schema = 'http://www.openarchives.org/OAI/2.0/oai_dc.xsd'
    @namespace = 'http://www.openarchives.org/OAI/2.0/oai_dc/'
    @element_namespace = 'dc'

    # Dublin Core Elements fields
    @fields = [:title, :description, :date, :identifier, :creator, :contributor, :coverage, :relation,
                 :type, :rights, :subject, :publisher, :language]
    # Format causing problems with Rails reserved keywords   :format
    # Source wasn't working as expected
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
end
