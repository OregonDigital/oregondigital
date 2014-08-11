module PdfOcr
  class Word
    include PdfOcr::AttributeNode
    attr_reader :document, :page

    def initialize(word_node, page)
      @document = word_node
      @page = page
    end

    def text
      document.text
    end

    def page
      @page
    end
  end
end
