module OregonDigital::ControlledVocabularies
  class Creator < ActiveFedora::Rdf::Resource
    include OregonDigital::RDF::Controlled

    use_vocabulary :lcnames
    use_vocabulary :uonames
    use_vocabulary :creator
    use_vocabulary :dummycreator
    use_vocabulary :ulan
    use_vocabulary :people
    use_vocabulary :wikidata

    # Make wikidata entity URIs usable to fetch.
    # Our gems don't handle their https redirect, and JSON is the default response which we have errors parsing, so force to NT.
    # For fetch purposes only, change URI from http://www.wikidata.org/entity/Q5343795 to https://www.wikidata.org/wiki/Special:EntityData/Q5343795.nt
    def fetch
      if self.rdf_subject.to_s.include?('wikidata') then
        self.rdf_subject.to_s.gsub!('http://www.wikidata.org/entity/', 'https://www.wikidata.org/wiki/Special:EntityData/')
        self.rdf_subject.to_s.concat('.nt')
      end

      super

      if self.rdf_subject.to_s.include?('wikidata') then
        self.rdf_subject.to_s.gsub!('https://www.wikidata.org/wiki/Special:EntityData/', 'http://www.wikidata.org/entity/')
        self.rdf_subject.to_s.gsub!('.nt', '')
      end
    end

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
      new_subject = OregonDigital::Vocabularies::DUMMYCREATOR.send(new_subject).to_s
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
