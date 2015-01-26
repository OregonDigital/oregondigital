module OregonDigital::RDF
  ##
  # A class of RdfResources to act as the primary/root resource associated
  # with a Datastream and ActiveFedora::Base object.
  #
  # @see OregonDigital::RdfResourceDatastream
  class ObjectResource < ActiveFedora::Rdf::ObjectResource
    include OregonDigital::RDF::DeepIndex
    configure :base_uri => "http://oregondigital.org/resource/"

    # No point in fetching - everything comes from Fedora and is loaded by the datastream.
    def fetch
    end

  end
end
