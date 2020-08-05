# frozen_string_literal:true

require 'hyrax/migrator/visibility_lookup'
require 'nokogiri'

module Hyrax::Migrator
  # A service to inspect the metadata and crosswalk the type to a model used for migration
  class VisibilityLookupPreflight < Hyrax::Migrator::VisibilityLookup
    attr_accessor :work

    def lookup_visibility
      result = lookup(read_groups)
      return '' if comparison_check(result)

      'read_groups does not agree with access_restrictions'
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
