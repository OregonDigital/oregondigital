module OregonDigital
  module Catalog
    module Defaults
      extend ActiveSupport::Concern
      included do
        configure_blacklight do |config|
          config.default_solr_params = {
              :qt => 'search',
              :rows => 10,
              :hl => true,
              :"hl.fl" => "desc_metadata__full_text_tsimv",
              :"hl.useFastVectorHighlighter" => true,
              :http_method => :get
          }
          config.http_method = :post
        end
      end
    end
  end
end
