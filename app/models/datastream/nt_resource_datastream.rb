require 'rdf/ntriples'

class Datastream::NtResourceDatastream < Datastream::RdfResourceDatastream
  def self.default_attributes
    super.merge(:controlGroup => 'M', :mimeType => 'text/plain')
  end

  def serialization_format
    :ntriples
  end
end
