require 'linkeddata'
require 'rdf/cli/vocab-loader'
module OregonDigital
  module RDF
    ##
    # Overrides some ruby-rdf specific stuff in RDF::VocabularyLoader.
    # One day it might also do some better/custom nvocab parsing.
    class VocabularyLoader < ::RDF::VocabularyLoader
      def fetch=(fetch)
        @fetch = fetch
      end

      def from_solution(solution)
        prefix_match = %r{\A#{@prefix}(.*)}
        return if !solution.resource.uri? || (match = prefix_match.match(solution.resource.to_s)).nil?
        name = match[1]

        # If there's a label or comment, the must either have no language, or be en
        label = solution[:label]
        comment = solution[:comment]

        return if label && label.has_language? && !label.language.to_s.start_with?("en")
        return if comment && comment.has_language? && !comment.language.to_s.start_with?("en")
        label = label.to_s.encode(Encoding::US_ASCII).strip.gsub(/\s+/m, ' ').gsub("\'", "\\\\\'")
        comment = comment.to_s.encode(Encoding::US_ASCII).strip.gsub(/\s+/m, ' ').gsub(/([\(\)])/, '\\\\\\1').gsub("\'", "\\\\\'")

        @subjects ||= []
        @subjects << solution.resource

        @output.write "    property #{name.to_sym.inspect}"
        @output.write ", :label => '#{label}'" unless label.empty?
        @output.write ", :comment =>\n      %(#{comment.scan(/\S.{0,60}\S(?=\s|$)|\S+/).join("\n        ")})" unless comment.empty?
        @output.puts
      rescue Encoding::UndefinedConversionError
      end

      # Actually executes the load-and-emit process - useful when using this
      # class outside of a command line - instantiate, set attributes manually,
      # then call #run
      def run
        @subjects = []
        @output.print %(# This file generated automatically using vocab-fetch from #{source}
        require 'rdf'
        module OregonDigital::Vocabularies
          class #{class_name} < ::RDF::#{"Strict" if @strict}Vocabulary("#{prefix}")
        ).gsub(/^        /, '') if @output_class_file
        if @fetch
          classes = ::RDF::Query.new do
            pattern [:resource, ::RDF.type, ::RDF::RDFS.Class]
            pattern [:resource, ::RDF::RDFS.label, :label], :optional => true
            pattern [:resource, ::RDF::RDFS.comment, :comment], :optional => true
          end

          owl_classes = ::RDF::Query.new do
            pattern [:resource, ::RDF.type, ::RDF::OWL.Class]
            pattern [:resource, ::RDF::RDFS.label, :label], :optional => true
            pattern [:resource, ::RDF::RDFS.comment, :comment], :optional => true
          end

          class_defs = graph.query(classes).to_a + graph.query(owl_classes).to_a
          unless class_defs.empty?
            @output.puts "\n    # Class definitions"
            class_defs.sort_by {|s| (s[:label] || s[:resource]).to_s}.each do |klass|
              from_solution(klass)
            end
          end

          properties = ::RDF::Query.new do
            pattern [:resource, ::RDF.type, ::RDF.Property]
            pattern [:resource, ::RDF::RDFS.label, :label], :optional => true
            pattern [:resource, ::RDF::RDFS.comment, :comment], :optional => true
          end

          dt_properties = ::RDF::Query.new do
            pattern [:resource, ::RDF.type, ::RDF::OWL.DatatypeProperty]
            pattern [:resource, ::RDF::RDFS.label, :label], :optional => true
            pattern [:resource, ::RDF::RDFS.comment, :comment], :optional => true
          end

          obj_properties = ::RDF::Query.new do
            pattern [:resource, ::RDF.type, ::RDF::OWL.ObjectProperty]
            pattern [:resource, ::RDF::RDFS.label, :label], :optional => true
            pattern [:resource, ::RDF::RDFS.comment, :comment], :optional => true
          end

          ann_properties = ::RDF::Query.new do
            pattern [:resource, ::RDF.type, ::RDF::OWL.AnnotationProperty]
            pattern [:resource, ::RDF::RDFS.label, :label], :optional => true
            pattern [:resource, ::RDF::RDFS.comment, :comment], :optional => true
          end

          ont_properties = ::RDF::Query.new do
            pattern [:resource, ::RDF.type, ::RDF::OWL.OntologyProperty]
            pattern [:resource, ::RDF::RDFS.label, :label], :optional => true
            pattern [:resource, ::RDF::RDFS.comment, :comment], :optional => true
          end
          prop_defs = graph.query(properties).to_a.sort_by {|s| (s[:label] || s[:resource]).to_s}
          prop_defs += graph.query(dt_properties).to_a.sort_by {|s| (s[:label] || s[:resource]).to_s}
          prop_defs += graph.query(obj_properties).to_a.sort_by {|s| (s[:label] || s[:resource]).to_s}
          prop_defs += graph.query(ann_properties).to_a.sort_by {|s| (s[:label] || s[:resource]).to_s}
          prop_defs += graph.query(ont_properties).to_a.sort_by {|s| (s[:label] || s[:resource]).to_s}
          unless prop_defs.empty?
            @output.puts "\n    # Property definitions"
            prop_defs.each do |prop|
              from_solution(prop)
            end
          end


          datatypes = ::RDF::Query.new do
            pattern [:resource, ::RDF.type, ::RDF::RDFS.Datatype]
            pattern [:resource, ::RDF::RDFS.label, :label], :optional => true
            pattern [:resource, ::RDF::RDFS.comment, :comment], :optional => true
          end

          dt_defs = graph.query(datatypes).to_a.sort_by {|s| (s[:label] || s[:resource]).to_s}
          unless dt_defs.empty?
            @output.puts "\n    # Datatype definitions"
            dt_defs.each do |dt|
              from_solution(dt)
            end
          end

          # Potential Repeats
          skos_concepts = ::RDF::Query.new do
            pattern [:resource, ::RDF.type, ::RDF::SKOS.Concept]
            pattern [:resource, ::RDF::RDFS.label, :label], :optional => true
            pattern [:resource, ::RDF::RDFS.comment, :comment], :optional => true
          end

          # @TODO: Don't add SKOS Concepts if they are already Classes or Properties
          concept_defs = graph.query(skos_concepts).to_a
          unless concept_defs.empty?
            @output.puts "\n    # Concept terms"
            concept_defs.sort_by {|s| (s[:label] || s[:resource]).to_s}.each do |klass|
              from_solution(klass) unless @subjects.include? klass[:resource]
            end
          end

          # Potential Repeats
          other_terms = ::RDF::Query.new do
            pattern [:resource, ::RDF.type, :type]
            pattern [:resource, ::RDF::RDFS.label, :label], :optional => true
            pattern [:resource, ::RDF::RDFS.comment, :comment], :optional => true
          end
          other_terms = graph.query(other_terms).to_a
          unless other_terms.empty?
            @output.puts "\n    # Other terms"
            other_terms.sort_by {|s| (s[:label] || s[:resource]).to_s}.each do |klass|
              from_solution(klass) unless @subjects.include? klass[:resource]
            end
          end

          unless @extra.empty?
            @output.puts "\n    # Extra definitions"
            @extra.each do |extra|
              @output.puts "    property #{extra.to_sym.inspect}"
            end
          end
        end
        # Query the vocabulary to extract property and class definitions
        @output.puts "  end\nend" if @output_class_file
      end
    end
  end
end
