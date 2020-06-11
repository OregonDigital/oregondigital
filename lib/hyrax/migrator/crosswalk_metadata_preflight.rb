# frozen_string_literal:true

require 'hyrax/migrator/crosswalk_metadata'

module Hyrax::Migrator
  # For use with MetadataPreflightRake
  class CrosswalkMetadataPreflight < Hyrax::Migrator::CrosswalkMetadata
    attr_accessor :errors, :result
    def initialize(crosswalk_metadata_file, crosswalk_overrides_file)
      super
      @errors = []
      @result = {}
    end

    # returns result hash
    def crosswalk
      super
    ensure
      @result[:errors] = @errors unless @errors.empty?
      @result
    end

    private

    # Given an OD2 predicate, returns associated property data or nil
    def lookup(predicate)
      result = super
      return result unless result.nil?

      @errors << "Predicate not found: #{predicate} during crosswalk"
      nil
    end

    ##
    # Generate the data necessary for a Rails nested attribute
    def attributes_data(object)
      result = super
      return result unless result.nil?

      @errors << "Invalid URI #{object} found in crosswalk"
      nil
    end
  end
end
