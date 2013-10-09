module OregonDigital
  module Catalog
    # TODO: Write some sortable fields.
    # What we had in the prototype was just boilerplate code.
    module SortFields
      extend ActiveSupport::Concern
      included do
        configure_blacklight do |config|
          # "sort results by" select (pulldown)
          # label in pulldown is followed by the name of the SOLR field to sort by and
          # whether the sort is ascending or descending (it must be asc or desc
          # except in the relevancy case).

          # If there are more than this many search results, no spelling ("did you
          # mean") suggestion is offered.
          config.spell_max = 5
        end
      end
    end
  end
end