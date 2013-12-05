module OregonDigital
  module RdfConfigurable

    def base_uri
      nil
    end

    def rdf_label
      RDF::RDFS.label
    end

    def type
      nil
    end

    def repository
      :parent
    end

    def configure(options = {})
      singleton_class.class_eval do {
          :base_uri => options[:base_uri],
          :rdf_label => options[:rdf_label],
          :type => options[:type],
          :repository => options[:repository]
        }.each do |name, value|
          # redefine reader methods only when required,
          # otherwise, use the ancestor methods
          if value
            define_method name do
              value
            end
          end
        end
      end
    end

  end
end
