class Document < GenericAsset
  has_file_datastream :name => 'thumbnail', :control_group => "E"
  has_file_datastream :name => 'content_ocr', :control_group => "E"
  has_metadata :name => 'leafMetadata', :type => Datastream::Yaml
  makes_derivatives do |obj|
    obj.transform_datastream :content, {:pages => {:output_path => obj.pages_location}}, :processor => :docsplit_processor
    obj.extract_text
    obj.create_thumbnail
    obj.workflowMetadata.has_thumbnail = true
    obj.update_leaf_metadata
    obj.save
  end

  def update_leaf_metadata
    leafMetadata_content = DocumentMetadataGenerator.call(self.decorate, :skip_preload => true).to_yaml
    leafMetadata.content = leafMetadata_content unless leafMetadata_content.blank?
  end

  def create_thumbnail
    transform_datastream :"page-1", {
        :thumb => {
            :datastream => 'thumbnail',
            :size => '120x120>',
            :file_path => thumbnail_location,
            :format => 'jpeg',
            :quality => '75'
        }
    }, :processor => :image_filesystem_processor
  end

  def extract_text
    transform_datastream :content, {
      :ocr => {
        :format => :html
      }
    },:processor => :pdf_text_processor
  end
  
  def thumbnail_location
    return ::Image.thumbnail_location(pid)
  end

  def ocr_location
    fd = output_location
    fd.extension = ""
    return Pathname.new(fd.path).join("ocr.html")
  end

  def ocr_content
    @ocr_content ||= File.read(ocr_location) if File.exist?(ocr_location)
  end

  def ocr_object
    @ocr_object ||= PdfOcr::Reader.new(ocr_content) unless ocr_content.blank?
  end

  def pages_location
    fd = output_location
    fd.extension = ""
    return Pathname.new(fd.path)
  end

  def output_location
    fd = OregonDigital::FileDistributor.new(pid)
    fd.base_path = base_pages_path
    fd
  end

  def base_pages_path
    Pathname.new(APP_CONFIG["document_pages_path"] || Rails.root.join("media", "document_pages"))
  end

end
