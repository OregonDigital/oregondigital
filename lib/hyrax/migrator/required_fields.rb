# frozen_string_literal:true

module Hyrax::Migrator
  # Methods to verify that required fields are present
  class RequiredFields
    attr_accessor :attributes
    def initialize(required_fields_file)
      @required_fields_file = required_fields_file
    end

    def verify_fields
      missing_fields = []
      fieldlist.map { |f| f['property'] }.each do |val|
        missing_fields << "missing required field: #{val}" if @attributes[val.to_sym].blank?
      end
      missing_fields
    end

    def fieldlist
      @fieldlist ||= YAML.load_file(@required_fields_file)['required']
    end
  end
end
