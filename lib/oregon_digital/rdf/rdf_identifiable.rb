module OregonDigital::RDF::RdfIdentifiable
  extend ActiveSupport::Concern
  def resource
    descMetadata.resource
  end
  module ClassMethods
    def from_uri(uri,values=[])
      uri = uri.to_s.gsub(OregonDigital::RDF::ObjectResource.base_uri,"")
      return self.find(uri)
    end
  end

end