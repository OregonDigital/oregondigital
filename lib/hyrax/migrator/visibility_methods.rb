# frozen_string_literal:true

module Hyrax::Migrator
  # methods for Visibility lookup services
  module VisibilityMethods
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
      elsif groups.include? 'University-of-Oregon'
        { visibility: 'uo' }
      elsif groups.include? 'Oregon-State'
        { visibility: 'osu' }
      else
        { visibility: 'restricted' }
      end
    end

    def comparison_check(visibility)
      unless access_restrictions.blank?
        return true if visibility[:visibility] != 'open'

        return false
      end
      true
    end
  end
end
