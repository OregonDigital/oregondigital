require 'linkeddata'

module OregonDigital::RDF
  ##
  # Adds add support for controlled vocabularies and
  # QuestioningAuthority to RdfResource classes.
  # @TODO: introduce graph context for provenance
  module Controlled

    def self.included(klass)
      klass.extend ClassMethods
      klass.configure :repository => :vocabs
      klass.property :hiddenLabel, :predicate => RDF::SKOS.hiddenLabel
      klass.send(:include, OregonDigital::RDF::DeepIndex) # Force deep indexing for controlled vocabs? Or keep seperate?
    end

    def qa_interface
      self.class.qa_interface
    end
    delegate :search, :get_full_record, :response, :results, :to => :qa_interface

    ##
    # Override set_subject! to find terms when (and only when) they
    # exist in the vocabulary
    def set_subject!(uri_or_str)
      vocab_matches = []
      begin
        uri = get_uri(uri_or_str)
        uri_or_str = uri
      rescue RuntimeError
      end
      self.class.vocabularies.each do |vocab, config|
        if uri_or_str.start_with? config[:prefix]
          # @TODO: is it good to need a full URI for a non-strict vocab?
          return super if config[:strict] == false
          uri_or_str = uri_or_str.to_s.gsub(config[:prefix], '')
          if config[:class].respond_to? uri_or_str
            uri_or_str = config[:class].send(uri_or_str)
            return super(uri_or_str)
          end
        else
          # this only matches if the term is explictly defined
          # @TODO: what about the possibility of terms like "entries" or
          # "map" which are methods but not defined properties?  does
          # this need to be patched in RDF::Vocabulary or am I missing
          # something?
          vocab_matches << config[:class].send(uri_or_str) if config[:class].respond_to? uri_or_str
        end
      end
      raise ControlledVocabularyError, "Term not in controlled vocabularies: #{uri_or_str}" if vocab_matches.empty?
      raise ControlledVocabularyError, "Term is ambiguous, could not choose a URI : #{uri_or_str}" if vocab_matches.length > 1
      uri_or_str = vocab_matches.first
      return super if self.class.uses_vocab_prefix?(uri_or_str) and not uri_or_str.kind_of? RDF::Node
    end

    def rdf_label
      labels = Array(self.class.rdf_label)
      labels += default_labels
      labels.each do |label|
        values = get_values(label, :language => :en)
        values = get_values(label) if values.blank?
        return values unless values.empty?
      end
      node? ? [] : [rdf_subject.to_s]
    end

    ##
    #  Class methods for adding and using controlled vocabularies
    module ClassMethods
      def use_vocabulary(name, opts={})
        raise ControlledVocabularyError, "Vocabulary undefined: #{name.to_s.upcase}" unless RDF_VOCABS.include? name
        opts[:class] = name_to_class(name) unless opts.include? :class
        opts.merge! RDF_VOCABS[name.to_sym]
        vocabularies[name] = opts
      end

      def vocabularies
        @vocabularies ||= {}.with_indifferent_access
      end

      ##
      # @return [Array<RDF::URI>] terms allowable by the registered StrictVocabularies
      #
      # Note: this does not necessarily list *all the term* allowable
      # by the class. Non-strict RDF::Vocabularies are not included in
      # this method's output.
      def list_terms
        terms = []
        vocabularies.each do |vocab, config|
          next unless config[:class].respond_to? :properties
          terms += config[:class].properties.select { |s| s.start_with? config[:class].to_s }
        end
        terms
      end

      ##
      # Gets data for all vocabularies used and loads it into the
      # configured repository. After running this new (and reloaded)
      # RdfResource objects of this class will have data from their
      # source web document.
      def load_vocabularies
        vocabularies.each do |name, config|
          load_vocab(name)
        end
      end

      def uses_vocab_prefix?(str)
        vocabularies.each do |vocab, config|
          return true if str.start_with? config[:prefix]
        end
        false
      end

      def qa_interface
        @qa_interface ||= QaRDF.new(self)
      end

      private

      def name_to_class(name)
        "OregonDigital::Vocabularies::#{name.upcase.to_s}".constantize
      end

      def load_vocab(name)
        return nil unless RDF_VOCABS[name.to_sym].include? :source
        cache = ActiveFedora::Rdf::Repositories.repositories[repository]
        graph = RDF::Graph.new(:data => cache, :context => RDF_VOCABS[name.to_sym][:source])
        graph.load(RDF_VOCABS[name.to_sym][:source])
        graph
      end

      ##
      # Implement QuestioningAuthority API
      class QaRDF
        attr_accessor :response, :raw_response

        def initialize(parent=nil)
          @parent = parent
        end

        ##
        # Not a very smart sparql search. It's mostly intended to be
        # overridden in subclasses, but it could also stand to be a bit
        # better as a baseline RDF vocab search.
        def search(q, sub_authority=nil)
          @sparql = SPARQL::Client.new(ActiveFedora::Rdf::Repositories.repositories[@parent.repository])
          self.response = sparql_starts_search(q)
          return response unless response.empty?
          self.response = sparql_contains_search(q)
        end

        def results
          response
        end

        def get_full_record(id, sub_authority)
        end
        
        private
          def sparql_starts_search(q)
            query = @sparql.query("SELECT DISTINCT ?s ?o WHERE { ?s ?p ?o. FILTER(strstarts(lcase(?o), '#{q.downcase}'))}")
            solutions_from_sparql_query(query)
          end

          def sparql_contains_search(q)
            query = @sparql.query("SELECT DISTINCT ?s ?o WHERE { ?s ?p ?o. FILTER(contains(lcase(?o), '#{q.downcase}'))}")
            solutions_from_sparql_query(query)
          end
          
          def solutions_from_sparql_query(query)
            solutions = []
            query.each_solution do |solution|
              solutions << { :id => solution[:s].to_s, :label => solution[:o].to_s } if @parent.uses_vocab_prefix? solution[:s]
            end
            solutions
          end
      end
    end

    class ControlledVocabularyError < StandardError; end
  end
end
