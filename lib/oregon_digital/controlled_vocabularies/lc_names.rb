module OregonDigital::ControlledVocabularies
  class LCNames < ActiveFedora::Rdf::Resource
    include OregonDigital::RDF::Controlled

    use_vocabulary :lcnames

    class QaLcNames < Qa::Authorities::Loc
      include OregonDigital::Qa::Caching
      def search(q, sub_authority=nil)
        super(q, 'names')
      end
    end

    @qa_interface = QaLcNames.new

  end
end
