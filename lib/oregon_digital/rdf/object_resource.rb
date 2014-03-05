module OregonDigital::RDF
  ##
  # A class of RdfResources to act as the primary/root resource associated
  # with a Datastream and ActiveFedora::Base object.
  #
  # @see OregonDigital::RdfResourceDatastream
  class ObjectResource < ActiveFedora::Rdf::ObjectResource
    configure :base_uri => "http://oregondigital.org/resource/"
  end
end
