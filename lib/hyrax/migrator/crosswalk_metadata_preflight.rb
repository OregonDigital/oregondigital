# frozen_string_literal:true

require 'hyrax/migrator/crosswalk_metadata'

module Hyrax::Migrator
  # For use with MetadataPreflightRake
  class CrosswalkMetadataPreflight < Hyrax::Migrator::CrosswalkMetadata
    attr_accessor :errors, :result, :work
    def initialize(crosswalk_metadata_file, crosswalk_overrides_file)
      super
      reset
    end

    # to allow result and errors to be reset automatically, return clone
    # force return from ensure block, otherwise super will return @result
    def crosswalk
      super
      result = @result.dup
      result[:errors] = @errors
      reset
      result
    end

    def graph
      work.descMetadata.graph
    end

    private

    def reset
      @result = {}
      @errors = []
    end

    # Given an OD2 predicate, returns associated property data or nil
    def lookup(predicate)
      result = super
      return result unless result.nil?

      @errors << "Predicate not found: #{predicate} during crosswalk"
      nil
    end

    def process(data, object)
      return data[:function].blank? ? object.to_s : send(data[:function].to_sym, object.to_s) unless illegal_string? object

      @errors <<  "illegal string object"
      return nil
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
