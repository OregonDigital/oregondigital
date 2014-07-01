module OregonDigital
  module Compound
    extend ActiveSupport::Concern
    
    def compound?
      od_content.length > 0
    end

    def od_content
      descMetadata.od_content.first_or_create
    end

  end
end
