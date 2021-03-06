# frozen_string_literal: true

require 'edtf'
module Hyrax::Migrator
  # check date fields for etdf formatting
  class EdtfCheck
    attr_accessor :work
    def initialize
      @errors = []
    end

    def check_date_fields
      edtf_fields.each do |field|
        @work.descMetadata.send(field).each do |value|
          @errors << "#{@work.pid}: in #{field}, #{value} is not in EDTF format" unless EDTF.parse(value).present?
        end
      end
      @errors
    end

    def edtf_fields
      %i[date acquisitionDate awardDate collectedDate issued viewDate]
    end
  end
end
