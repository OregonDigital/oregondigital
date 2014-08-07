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

    def text(focus_words=[])
      @text ||= words.map do |word|
        if focus_words.include?(word)
          "{{{#{word.text}}}}"
        else
          word.text
        end
      end.join(" ")
    end

    private

    def document_words
      document.css("word")
    end
  end
end
