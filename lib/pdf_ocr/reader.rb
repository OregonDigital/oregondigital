module PdfOcr
  class Reader
    attr_reader :document, :content

    def initialize(content)
      self.content = content
    end

    def pages
      @pages ||= document_pages.each_with_index.map{|page_node, index| Page.new(page_node, index+1)}
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
