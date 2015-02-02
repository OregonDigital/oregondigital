module OregonDigital
  module Catalog
    module Facets
      extend ActiveSupport::Concern
      included do
        configure_blacklight do |config|
          controlled_vocabularies.each do |key|
            # Register with a filler label that gets re-configured by config/initializers/facet_patch.rb
            config.add_facet_field solr_name("desc_metadata__#{key}_label", :facetable), :helper_method => :controlled_view, :label => "filler$#{key}", :limit => 10
          end
          config.add_facet_field("date_decades_ssim", :label => "Decade", :limit => 10, :sort => "desc")
          config.add_facet_fields_to_solr_request!
        end
      end

      module ClassMethods

        ##
        # Returns an array of all controlled vocabulary properties.
        # TODO: Move this to ControlledVocabulary class.
        def controlled_vocabularies
          Datastream::OregonRDF.properties.map do |key, property|
            instance = property[:class_name].new if property[:class_name]
            if instance && (instance.class.ancestors.include?(OregonDigital::RDF::Controlled) || (instance.respond_to?(:resource) && instance.resource.class.ancestors.include?(OregonDigital::RDF::Controlled)))
              key
            end
          end.compact
        end
      end
    end
  end
end
