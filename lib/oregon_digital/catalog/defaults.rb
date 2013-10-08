module OregonDigital
  module Catalog
    module Defaults
      extend ActiveSupport::Concern
      included do
        blacklight_config do |config|
          config.default_solr_params = {
              :qt => 'search',
              :rows => 10
          }
          # Have BL send all facet field names to Solr, which has been the default
          # previously. Simply remove these lines if you'd rather use Solr request
          # handler defaults, or have no facets.
          config.default_solr_params[:'facet.field'] = config.facet_fields.keys
        end
      end
    end
  end
end