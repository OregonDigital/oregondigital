module OregonDigital::ControlledVocabularies
  class Subject < ActiveFedora::Rdf::Resource
    include OregonDigital::RDF::Controlled
    
    #metdata librarians want multiple authoritative sources with dct.subject
    use_vocabulary :lcsh
    use_vocabulary :lcnames
    use_vocabulary :tgm
    use_vocabulary :aat
    use_vocabulary :subject
    use_vocabulary :lc_orgs
    use_vocabulary :creator
    use_vocabulary :people
    use_vocabulary :itis
    use_vocabulary :ubio

    class QaLcsh < Qa::Authorities::Loc
      include OregonDigital::Qa::Caching
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
