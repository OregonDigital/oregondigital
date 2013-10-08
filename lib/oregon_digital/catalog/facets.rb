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
          config.add_facet_field solr_name('desc_metadata__hasFormat',:facetable), :label => 'Format'
          config.add_facet_field solr_name('desc_metadata__date', :facetable), :label => 'Publication Year', :single => true
          config.add_facet_field solr_name('desc_metadata__subject', :facetable), :label => 'Topic', :limit => 20
          config.add_facet_field solr_name('desc_metadata__location', :facetable), :label => 'Region'
          config.add_facet_field solr_name('desc_metadata__set', :facetable), :label => 'Collection'#, :helper_method => :get_collection_title
        end
      end
    end
  end
end