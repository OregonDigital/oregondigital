class Document < GenericAsset
  makes_derivatives do |obj|
    obj.transform_datastream :content, {:pages => {:output_path => obj.pages_location}}, :processor => :docsplit_processor
    obj.save
  end

  def pages_location
    fd = OregonDigital::FileDistributor.new(pid)
    fd.base_path = base_pages_path
    fd.extension = ""
    return Pathname.new(fd.path)
  end

  def base_pages_path
    Pathname.new(APP_CONFIG["document_pages_path"] || Rails.root.join("media", "document_pages"))
  end

end
