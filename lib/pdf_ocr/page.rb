module PdfOcr
  class Page
    include PdfOcr::AttributeNode
    attr_reader :document

    def initialize(page_node)
      @document = page_node
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
