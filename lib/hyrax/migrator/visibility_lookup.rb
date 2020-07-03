# frozen_string_literal:true

require 'nokogiri'

module Hyrax::Migrator
  # A class to inspect the metadata and crosswalk the type to a model used for migration
  class VisibilityLookup
    def lookup_visibility
      result = lookup(read_groups)
      return result if comparison_check(result)

      nil
    end

    private

    # this should provide access to the read_groups metadata
    # in preflight, use the item
    # in the migrator use the workflow metadata
    def read_groups; end

    #  metadata field on asset.
    # in preflight, use descMetadata
    # in migrator, use work env attributes
    def access_restrictions; end

    def lookup(groups)
      if groups.include? 'public'
        { visibility: 'open' }
      elsif (groups.include? 'University-of-Oregon') || (groups.include? 'Oregon-State')
        { visibility: 'authenticated' }
      else
        { visibility: 'restricted' }
      end
    end

    def comparison_check(visibility)
      unless access_restrictions.blank?
        return true if visibility[:visibility] == 'authenticated'

        return false
      end
      true
    end
  end
end
