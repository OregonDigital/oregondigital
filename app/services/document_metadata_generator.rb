class DocumentMetadataGenerator
  attr_accessor :document
  
  def self.call(document, opts={})
    new(document, opts).metadata
  end

  def initialize(document, opts={})
    @document = document
    preload_metadata unless opts[:skip_preload]
  end

  def preload_metadata
    unless preloaded_data.to_h.blank?
      @document_metadata = document.leafMetadata.inner_hash.to_h.stringify_keys
    end
  end

  def preloaded_data
    preloaded_data = document.leafMetadata.inner_hash
    return {} if preloaded_data.blank?
    preloaded_data
  end

  def metadata
    @document_metadata ||= {:pages => page_metadata}
  end

  def page_metadata
    document.page_datastreams.map{|page_datastream| PageMetadataGenerator.call(document, page_datastream)}
  end

  class PageMetadataGenerator
    attr_accessor :page, :document
    def self.call(document, page)
      new(document, page).metadata
    end

    def initialize(document, page)
      @document ||= document
      @page ||= page
    end

    def metadata
      {:size => size_metadata}
    end

    def size_metadata
      {:width => width, :height => height}
    end

    private

    def width
      @width ||= image_object[:width]
    end

    def height
      @height ||= image_object[:height]
    end

    def image_object
      @image_object ||= MiniMagick::Image.open(page_path)
    end

    def page_path
      document.pages_location.join("normal-"+page[0]+".jpg")
    end
  end
end
