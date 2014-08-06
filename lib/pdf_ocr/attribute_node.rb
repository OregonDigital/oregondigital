module PdfOcr
  module AttributeNode
    extend ActiveSupport::Concern

    def method_missing(meth_name, *args, &block)
      return super unless document_attributes.include?(meth_name.to_s)
      return get_attribute(meth_name.to_s)
    end

    def document_attributes
      document.attributes
    end

    def get_attribute(attribute)
      attribute = document_attributes[attribute.to_s].try(:value)
      return if attribute.nil?
      attribute.to_f
    end

    module ClassMethods
      def attributes
        []
      end
    end
  end
end
