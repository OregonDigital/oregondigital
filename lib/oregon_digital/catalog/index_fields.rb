module OregonDigital
  module Catalog
    module IndexFields
      extend ActiveSupport::Concern
      included do
        configure_blacklight do |config|
          # solr fields to be displayed in the index (search results) view
          #   The ordering of the field names is the order of the display
          for field in [:description, :modified]
            label = OregonDigital::Metadata::FieldTypeLabel.for(field)
            config.add_index_field solr_name("desc_metadata__#{field}", :displayable), :label => label
          end
        end
      end
    end
  end
end
