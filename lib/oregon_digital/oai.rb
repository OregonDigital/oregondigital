module OregonDigital::OAI
  extend ActiveSupport::Concern
  included do
    def parsed_modified_date
      Time.parse(modified_date).utc
    end
  end
  module ClassMethods
    def map_oai_dc
      {:subject => :subject,
       :description => :description,
       :creator => :creator,
       :contributor => :contributor
      }
    end
  end
end
