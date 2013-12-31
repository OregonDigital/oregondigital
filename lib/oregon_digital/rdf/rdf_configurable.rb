module OregonDigital::RDF
  module RdfConfigurable
    ##
    # Module to include configurable class-wide properties common to RdfResource
    # and RdfResourceDatastream. It does its work at the class level, and
    # is meant to be extended.
    # Define configuration as follows:
    # Define properties at the class level with:
    #
    #    configure :base_uri => "http://oregondigital.org/resource/", :repository => :parent
    # Available properties are base_uri, rdf_label, type, and repository

    def base_uri
      nil
    end

    def rdf_label
      nil
    end

    def type
      nil
    end

    def repository
      :parent
    end

    # API method for configuring class properties an RDF Resource may need.
    # This is an alternative to overriding the methods extended with this module.
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
