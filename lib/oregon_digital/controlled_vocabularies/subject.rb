module OregonDigital::ControlledVocabularies
  class Subject < OregonDigital::RDF::RdfResource
    include OregonDigital::RDF::Controlled

    use_vocabulary :lcsh

    class QaLcsh < Qa::Authorities::Loc
      def search(q, sub_authority=nil)
        super(q, 'subjects')
      end
      def get_id_from_url(url)
        url
      end
    end

    @qa_interface = QaLcsh.new
  end
end
