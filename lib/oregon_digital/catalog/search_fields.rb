module OregonDigital
  module Catalog
    # TODO: Fix this.
    # This should include more search fields in the future - the ones we had configured in prototype
    # were just boilerplate.
    module SearchFields
      extend ActiveSupport::Concern
      included do
        configure_blacklight do |config|
          # "fielded" search configuration. Used by pulldown among other places.
          # For supported keys in hash, see rdoc for Blacklight::SearchFields
          #
          # Search fields will inherit the :qt solr request handler from
          # config[:default_solr_parameters], OR can specify a different one
          # with a :qt key/value. Below examples inherit, except for subject
          # that specifies the same :qt as default for our own internal
          # testing purposes.
          #
          # The :key is what will be used to identify this BL search field internally,
          # as well as in URLs -- so changing it after deployment may break bookmarked
          # urls.  A display label will be automatically calculated from the :key,
          # or can be specified manually to be different.

          # This one uses all the defaults set by the solr request handler. Which
          # solr request handler? The one set in config[:default_solr_parameters][:qt],
          # since we aren't specifying it otherwise.

          config.add_search_field 'all_fields', :label => 'All Fields' do |field|
            field.solr_parameters = {:qf => "all_text_timv"}
          end
          %w{title description creator lcsubject date institution}.each do |field_name|
            config.add_search_field(field_name) do |field|
              field.solr_parameters = {:qf => Solrizer.solr_name("desc_metadata__#{field_name}", :searchable)}
            end
          end
        end
      end
    end
  end
end
