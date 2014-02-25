class Document < GenericAsset
  makes_derivatives do |obj|
    obj.transform_datastream :content, {:pages => {:output_path => obj.pages_location}}, :processor => :docsplit_processor
  end

  def pages_location
    fd = OregonDigital::FileDistributor.new(pid)
    fd.base_path = APP_CONFIG["document_pages_path"] || Rails.root.join("media", "document_pages")
    fd.extension = ""
    return Pathname.new(fd.path)
  end

end
