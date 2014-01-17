module OregonDigital::ControlledVocabularies
  class Subject < OregonDigital::RDF::RdfResource
    include OregonDigital::RDF::Controlled

    use_vocabulary :lcsh

    class QaLcsh < Qa::Authorities::Loc
      def search(q, sub_authority=nil)
        super(q, 'subjects')
      end

      def loc_response_to_qa(data)
        response = super(data)
        for link in data.links
          response["id"] = link[1] if link[0].nil?
        end
        return response
      end
    end

    @qa_interface = QaLcsh.new
  end
end
