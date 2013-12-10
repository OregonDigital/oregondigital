require 'rdf/ntriples'

class OregonDigital::NtResourceDatastream < OregonDigital::RdfResourceDatastream
  def self.default_attributes
    super.merge(:controlGroup => 'M', :mimeType => 'text/plain')
  end

  def serialization_format
    :ntriples
  end
end
