## TODO: GET RID OF THIS! It's required now because ActiveFedora::Rdf::Identifiable doesn't support custom base_uris
# in ObjectResources.
module OregonDigital::RDF::Identifiable
  extend ActiveSupport::Concern
  module ClassMethods
    def from_uri(uri,_)
      uri = uri.to_s.gsub(OregonDigital::RDF::ObjectResource.base_uri,"")
      return self.find(uri)
    end
  end
end
