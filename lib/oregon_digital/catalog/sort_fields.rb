module OregonDigital
  module Catalog
    # TODO: Write some sortable fields.
    # What we had in the prototype was just boilerplate code.
    module SortFields
      extend ActiveSupport::Concern
      included do
        configure_blacklight do |config|
          config.add_sort_field "#{ActiveFedora::SolrService.solr_name("desc_metadata__title", :sortable)} asc", :label => "Title A-Z"
          config.add_sort_field "#{ActiveFedora::SolrService.solr_name("desc_metadata__title", :sortable)} desc", :label => "Title Z-A"
          config.add_sort_field "system_create_dtsi desc", :label => "Recently Added"

          # If there are more than this many search results, no spelling ("did you
          # mean") suggestion is offered.
          config.spell_max = 5
        end
      end
    end
  end
end
