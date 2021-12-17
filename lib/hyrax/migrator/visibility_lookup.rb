# frozen_string_literal:true

require 'nokogiri'

module Hyrax::Migrator
  # A class to inspect the metadata and crosswalk the type to a model used for migration
  class VisibilityLookup
    include Hyrax::Migrator::VisibilityMethods
    def lookup_visibility
      result = lookup(read_groups)
      return result if comparison_check(result)

      nil
    end
  end
end
