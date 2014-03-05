class OregonDigital::RdfResourceDatastream < ActiveFedora::RDFDatastream
  def resource_class
    OregonDigital::RDF::ObjectResource
  end
end
