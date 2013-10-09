module OregonDigital
  module Catalog
    module Defaults
      extend ActiveSupport::Concern
      included do
        configure_blacklight do |config|
          config.default_solr_params = {
              :qt => 'search',
              :rows => 10
          }
        end
      end
    end
  end
end