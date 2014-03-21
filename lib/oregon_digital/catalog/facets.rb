module OregonDigital
  module Catalog
    module Facets
      extend ActiveSupport::Concern
      included do
        configure_blacklight do |config|
          # solr fields that will be treated as facets by the blacklight application
          #   The ordering of the field names is the order of the display
          #
          # Setting a limit will trigger Blacklight's 'more' facet values link.
          # * If left unset, then all facet values returned by solr will be displayed.
          # * If set to an integer, then "f.somefield.facet.limit" will be added to
          # solr request, with actual solr request being +1 your configured limit --
          # you configure the number of items you actually want _tsimed_ in a page.
          # * If set to 'true', then no additional parameters will be sent to solr,
          # but any 'sniffed' request limit parameters will be used for paging, with
          # paging at requested limit -1. Can sniff from facet.limit or
          # f.specific_field.facet.limit solr request params. This 'true' config
          # can be used if you set limits in :default_solr_params, or as defaults
          # on the solr side in the request handler itself. Request handler defaults
          # sniffing requires solr requests to be made with "echoParams=all", for
          # app code to actually have it echo'd back to see it.
          #
          # :show may be set to false if you don't want the facet to be drawn in the
          # facet bar
          controlled_vocabularies.each do |key|
            config.add_facet_field solr_name("desc_metadata__#{key}", :facetable), :helper_method => :controlled_view, :label => I18n.t("oregondigital.catalog.facet.#{key}",:default => key.humanize)
            config.add_facet_field solr_name("desc_metadata__#{key}_label", :facetable), :show => false
          end
          config.add_facet_fields_to_solr_request!
        end
      end

      module ClassMethods
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
