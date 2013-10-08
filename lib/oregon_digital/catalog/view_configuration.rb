module OregonDigital
  module Catalog
    module ViewConfiguration
      extend ActiveSupport::Concern
      included do
        configure_blacklight do |config|
          # solr field configuration for search results/index views
          config.index.show_link = solr_name('desc_metadata__title', :displayable)
          config.index.record_display_type = solr_name('has_model', :symbol)

          # solr field configuration for document/show views
          config.show.html_title = solr_name('desc_metadata__title', :displayable)
          config.show.heading = solr_name('desc_metadata__title', :displayable)
          config.show.display_type = solr_name('has_model', :symbol)
        end
      end
    end
  end
end