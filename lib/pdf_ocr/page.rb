module PdfOcr
  class Page
    include PdfOcr::AttributeNode
    attr_reader :document, :page_number

    def initialize(page_node, page)
      @document = page_node
      @page_number = page
    end

    def words
      @words ||= document_words.map{|word_node| Word.new(word_node, self)}
    end

    private

    def document_words
      document.css("word")
    end
  end
end
