module OregonDigital::ControlledVocabularies
  class Creator < ActiveFedora::Rdf::Resource
    include OregonDigital::RDF::Controlled

    use_vocabulary :lcnames
    use_vocabulary :uonames
    use_vocabulary :creator

    def initialize(*args)
      super
      if @new_label
        self << RDF::Statement.new(rdf_subject, RDF::SKOS.prefLabel, @new_label)
        @new_label = nil
        persist!
      end
    end

    def set_subject!(uri_or_str)
      if uri_or_str.to_s.start_with?("http")
        super
      else
        new_subject = uri_or_str.to_s.gsub(" ", "").gsub(/[^A-z]/,'').camelize
        new_subject = OregonDigital::Vocabularies::CREATOR.send(new_subject).to_s
        super(new_subject)
        @new_label = uri_or_str.to_s
      end
    end

    class QaLcNames < Qa::Authorities::Loc
      include OregonDigital::Qa::Caching
      def search(q, sub_authority=nil)
        super(q, 'names')
      end
    end

    @qa_interface = QaLcNames.new

  end
end
