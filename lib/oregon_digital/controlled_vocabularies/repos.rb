module OregonDigital::ControlledVocabularies
  class Repos < ActiveFedora::Rdf::Resource
    include OregonDigital::RDF::Controlled

    use_vocabulary :lc_orgs
    use_vocabulary :repository
    use_vocabulary :lcnames
    use_vocabulary :ulan
    use_vocabulary :lcsh

    class QaLcNames < Qa::Authorities::Loc
      include OregonDigital::Qa::Caching
      def search(q, sub_authority=nil)
        super(q, 'repos')
      end
    end

    @qa_interface = QaLcNames.new

  end
end
