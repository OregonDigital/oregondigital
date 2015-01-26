module OregonDigital::RDF
  class ComplexGraphConverter
    attr_accessor :source_graph, :result
    def initialize(source_graph)
      @source_graph = source_graph
      @result = RDF::Graph.new
    end

    def run
      copy_root_statements
      copy_members
      result
    end

    private

    def copy_root_statements
      source_statements.each do |s|
        next unless s.subject == source_graph.rdf_subject
        next if s.predicate == OregonDigital::Vocabularies::OREGONDIGITAL.contents
        result << s
      end
    end

    def copy_members
      ProxyCreator.new(source_graph, result, contents_node, source_graph).run
    end

    def contents_node
      RDF::Graph.new << source_graph.query([contents, nil, nil]) if contents
    end

    def contents
      source_graph.query([source_graph.rdf_subject, OregonDigital::Vocabularies::OREGONDIGITAL.contents, nil]).to_a.first.try(:object)
    end

    def source_statements
      source_graph.statements.to_a
    end

    class ProxyCreator
      attr_accessor :source_graph, :proxy, :result, :root
      def initialize(source_graph, result, proxy, root)
        @source_graph = source_graph
        @result = result
        @proxy = proxy
        @root = root
      end

      def run
        add_references if first_node_references
        if rest_present?
          ProxyCreator.new(source_graph, result, rest_node, new_proxy).run
        else
          add_last
        end
      end

      private

      def add_last
        result << [source_graph.rdf_subject, OregonDigital::Vocabularies::IANA["last"], new_proxy.rdf_subject]
      end

      def rest_present?
        rest && rest != RDF.nil
      end

      def add_references
        result << [source_graph.rdf_subject, OregonDigital::Vocabularies::OREGONDIGITAL.contents, first_node_references]
        new_proxy << [new_proxy.rdf_subject, OregonDigital::Vocabularies::ORE.proxyFor, first_node_references]
        if root == source_graph
          set_first
        else
          set_next_and_previous
        end
        result << new_proxy
      end

      def set_next_and_previous
        result << [root.rdf_subject, OregonDigital::Vocabularies::IANA["next"], new_proxy.rdf_subject]
        result << [new_proxy.rdf_subject, OregonDigital::Vocabularies::IANA["previous"], root.rdf_subject]
      end

      def set_first
        result << [source_graph.rdf_subject, OregonDigital::Vocabularies::IANA["first"], new_proxy.rdf_subject]
      end

      def new_proxy
        @new_proxy ||= ActiveFedora::Rdf::Resource.new
      end

      def first_node
        @first_node ||= RDF::Graph.new << source_graph.query([first, nil, nil]) if first
        @first_node ||= RDF::Graph.new
      end

      def rest_node
        @rest_node ||= RDF::Graph.new << source_graph.query([rest, nil, nil]) if rest
        @rest_node ||= RDF::Graph.new
      end

      def first_node_references
        first_node.query([nil, RDF::DC.references, nil]).to_a.first.object
      end

      def first
        @first ||= proxy.query([nil, RDF.first, nil]).to_a.first.try(:object)
      end

      def rest
        @rest ||= proxy.query([nil, RDF.rest, nil]).to_a.first.try(:object)
      end
    end
  end
end
