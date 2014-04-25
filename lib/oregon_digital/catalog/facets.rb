module OregonDigital
  module Catalog
    module Facets
      extend ActiveSupport::Concern
      included do
        ##
        # TODO: Fix this.
        # Blacklight advanced search loads CatalogController before I18n rules are in place.
        # So we need to load the facet labels AFTER initialization.
        # In the long term we should patch Facet objects in BL to accept a proc which it caches the result of.
        def initialize(*args)
          result = super
          self.class.configure_facets
          return result
        end
      end

      module ClassMethods
        ##
        # Configures facets for all controlled vocabularies.
        # Pulls labels from I18n configuration if possible
        def configure_facets
          return unless blacklight_config.facet_fields.blank?
          configure_blacklight do |config|
            controlled_vocabularies.each do |key|
              config.add_facet_field solr_name("desc_metadata__#{key}_label", :facetable), :helper_method => :controlled_view, :label => I18n.t("oregondigital.catalog.facet.#{key}", :default => key.humanize), :limit => 10
            end
            config.add_facet_fields_to_solr_request!
          end
        end

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
