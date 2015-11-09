module OregonDigital::OAI::Concern
  extend ActiveSupport::Concern
  included do
    def parsed_modified_date
      Time.parse(modified_date).utc
    end
  end
  module ClassMethods
    def string_fields
      @string_fields = [ :title, :description, :date, :identifier]
    end
    def uri_fields
      @uri_fields = [:creator, :lcsubject, :type, :format, :rights]
    end

  end
end

