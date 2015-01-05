module OregonDigital::ControlledVocabularies
  class Creator < ActiveFedora::Rdf::Resource
    include OregonDigital::RDF::Controlled

    use_vocabulary :lcnames
    use_vocabulary :uonames
    use_vocabulary :creator

    def initialize(*args)
      args[0] = assign_subject(args.first) unless args.first.to_s.start_with?("http")
      super
      if @new_label
        self << RDF::Statement.new(rdf_subject, RDF::SKOS.prefLabel, @new_label)
        @new_label = nil
        persist!
      end
    end

    def assign_subject(string)
      string = string.to_s
      new_subject = string.gsub(" ", "").gsub(/[^A-z]/,'').camelize
      new_subject = OregonDigital::Vocabularies::CREATOR.send(new_subject).to_s
      @new_label = string
      new_subject
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
