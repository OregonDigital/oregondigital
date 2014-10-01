module OregonDigital::RDF
  class TripleStrictVocabulary < ::RDF::StrictVocabulary
    class << self
      def method_missing(property, *args, &block)
        return super if %w(to_ary).include?(property.to_s)
        return [to_s, property].join('') if has_property?(property)
        super
      end

      def respond_to_missing?(method, include_private=false)
        has_property?(method) || super
      end

      def has_property?(property)
        resource = vocab_resource(property)
        resource.rdf_label.present? && resource.rdf_label.first != resource.rdf_subject.to_s
      end

      def vocab_resource(property)
        begin
          uri_str = [to_s, property].join('')
          OregonDigital::RDF::VocabResource.new(uri_str)
        rescue
          ActiveFedora::Rdf::Resource.new
        end
      end
    end
  end
end
