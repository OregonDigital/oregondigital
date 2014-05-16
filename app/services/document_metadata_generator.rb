class DocumentMetadataGenerator
  attr_accessor :document
  
  def self.call(document)
    new(document).metadata
  end

  def initialize(document)
    @document = document
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
      document.pages_location.join(page[0]+".png")
    end
  end
end
