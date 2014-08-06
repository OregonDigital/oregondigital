module PdfOcr
  class Reader
    attr_reader :document, :content

    def initialize(content)
      self.content = content
    end

    def pages
      @pages ||= document_pages.map{|page_node| Page.new(page_node)}
    end

    def words
      @words ||= pages.map(&:words).flatten
    end

    private

    def content=(content)
      @content = content
      @document = Nokogiri::HTML(content)
    end

    def document_pages
      document.css("page")
    end
  end

end
