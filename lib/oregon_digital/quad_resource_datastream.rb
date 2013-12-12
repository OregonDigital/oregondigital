class OregonDigital::QuadResourceDatastream < OregonDigital::RdfResourceDatastream
  def self.default_attributes
    super.merge(:controlGroup => 'M', :mimeType => 'text/plain')
  end

  def serialization_format
    :nquads
  end
end
