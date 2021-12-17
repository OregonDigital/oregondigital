# frozen_string_literal:true

require 'hyrax/migrator/visibility_lookup'
require 'nokogiri'

module Hyrax::Migrator
  # A service to inspect the metadata and crosswalk the type to a model used for migration
  class VisibilityLookupPreflight < Hyrax::Migrator::VisibilityLookup
    attr_accessor :work

    def lookup_visibility
      result = super
      return result[:visibility] unless result.nil?

      'error: read_groups does not agree with access_restrictions'
    end

    private

    def read_groups
      @work.read_groups
    end

    def access_restrictions
      @work.descMetadata.accessRestrictions
    end
  end
end
