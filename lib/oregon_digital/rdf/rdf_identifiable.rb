##
# This module is included to allow for an ActiveFedora::Base object to be set as the class_name for an
# RdfResource.
# Enables functionality like:
#   base = ActiveFedora::Base.new('oregondigital:1')
#   base.title = 'test'
#   base.save
#   subject.descMetadata.set = base
#   subject.descMetadata.set # => <ActiveFedora::Base>
#   subject.descMetadata.set.title # => 'test'
module OregonDigital::RDF::RdfIdentifiable
  extend ActiveSupport::Concern
  ##
  # Defines which resource defines this ActiveFedora object.
  # This is required for OregonDigital::RDF::RdfResource#set_value to append graphs.
  # @TODO: Consider allowing multiple defining metadata streams.
  def resource
    descMetadata.resource
  end
  module ClassMethods
    ##
    # Finds the appropriate ActiveFedora::Base object given a URI from a graph.
    # Expected by the API in OregonDigital::RDF::RdfResource
    # @TODO: Generalize this.
    # @see OregonDigital::RDF::RdfResource.from_uri
    # @param [RDF::URI] uri URI that is being looked up.
    def from_uri(uri,_)
      uri = uri.to_s.gsub(OregonDigital::RDF::ObjectResource.base_uri,"")
      return self.find(uri)
    end
  end

end