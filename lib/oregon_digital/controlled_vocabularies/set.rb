module OregonDigital::ControlledVocabularies
  class Set < OregonDigital::RDF::ObjectResource
    include OregonDigital::RDF::Controlled

    def self.repository
      :parent
    end

    use_vocabulary :set

    class QaSet
      attr_accessor :response, :raw_response

      def initialize(parent=nil)
        @parent = parent
      end

      # Pulls names and ids of GenericCollection objects from Solr.
      # `sub_authority` is ignored for sets.
      def search(q, sub_authority=nil)
        self.response = []
        field = Solrizer.solr_name("desc_metadata__title", :searchable)
        for set in GenericCollection.where("#{field}:*#{q}*").to_a
          resource = set.resource
          response << {:id => resource.rdf_subject.to_s, :label => resource.rdf_label.first}
        end
      end

      # TermsController requires this for now
      def results
        self.response
      end
    end

    @qa_interface = QaSet.new
  end
end
