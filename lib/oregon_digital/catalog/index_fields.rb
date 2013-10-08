module OregonDigital
  module Catalog
    module IndexFields
      extend ActiveSupport::Concern
      included do
        blacklight_config do |config|
          # solr fields to be displayed in the index (search results) view
          #   The ordering of the field names is the order of the display
          config.add_index_field solr_name('desc_metadata__subject', :displayable), :label => 'Subject:'
          config.add_index_field solr_name('desc_metadata__description', :displayable), :label => 'Description:'
          config.add_index_field solr_name('desc_metadata__modified', :displayable), :label => 'Record Modified:'
        end
      end
    end
  end
end