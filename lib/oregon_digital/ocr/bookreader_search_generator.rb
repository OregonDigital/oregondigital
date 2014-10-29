module OregonDigital::OCR
  class BookreaderSearchGenerator
    def self.call(document,query)
      new(document,query).result
    end

    attr_reader :document, :query

    def initialize(document, query)
      @document = document
      @query = query.to_s.downcase
    end

    def result
      return not_indexed if ocr_object.blank?
      {
        :matches => matches_hash
      }
    end

    def not_indexed
      {
        :indexed => false,
        :matches => []
      }
    end

    private

    def ocr_object
      @ocr_object ||= document.ocr_object
    end

    def matches_hash
      matches.group_by{|x| x.page}.map{|page, matched_words| page_matches(page, matched_words)}
    end

    def page_matches(page, matched_words)
      {
        :text => page.text(matched_words),
        :par => [
          :page => page.page_number,
          :boxes => matched_words.map{|word| word_box(word)}
        ]
      }
    end

    def word_box(word)
      {
        :r => ratio(word, :xmax),
        :l => ratio(word, :xmin),
        :b => ratio(word, :ymax),
        :t => ratio(word, :ymin),
        :page => word.page.page_number
      }
    end

    def ratio(word, attribute)
      dimension = attribute.to_s.starts_with?("x") ? :width : :height
      derivative_page_size = page_metadata[word.page.page_number-1][:size][dimension]
      original_page_size = word.page.send(dimension)
      ratio = derivative_page_size/original_page_size
      word.send(attribute)*ratio
    end

    def document_metadata
      @document_metadata ||= DocumentMetadataGenerator.call(document)
    end

    def page_metadata
      @page_metadata ||= document_metadata["pages"]
    end

    def matches
      return @matches if @matches
      word_queries = query.strip.split(" ")
      @matches = []
      ocr_object.words.each_with_index do |word, index|
        next unless word.text.downcase.include?(word_queries.first)
        next unless index+word_queries.length-1 < ocr_object.words.length
        puts ocr_object.words[index..index+word_queries.length-1].map(&:text).join(" ")
        if ocr_object.words[index..index+word_queries.length-1].map(&:text).join(" ").downcase.include?(query)
          @matches |= ocr_object.words[index..index+word_queries.length-1]
        end
      end
      @matches
    end

  end
end
