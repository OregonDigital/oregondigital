# frozen_string_literal:true

require 'hyrax/migrator/crosswalk_metadata_preflight'
require 'hyrax/migrator/required_fields'
require 'hyrax/migrator/asset_status'
require 'hyrax/migrator/visibility_lookup_preflight'
require 'hyrax/migrator/cpd_check'
require 'hyrax/migrator/edtf_check'

module Hyrax::Migrator
  # Initialize and wrap all the preflight services for the preflight check
  class PreflightCheckServices
    attr_accessor :members
    def initialize(files, work_dir, pidlist)
      @members = {
        crosswalk: ServiceWrapper.new(Hyrax::Migrator::CrosswalkMetadataPreflight.new(files[:crosswalk], files[:crosswalk_overrides]), :crosswalk, :work=),
        required: ServiceWrapper.new(Hyrax::Migrator::RequiredFields.new(files[:required_fields]), :verify_fields, :attributes=),
        status: ServiceWrapper.new(Hyrax::Migrator::AssetStatus.new, :verify_status, :work=),
        visibility: ServiceWrapper.new(Hyrax::Migrator::VisibilityLookupPreflight.new, :lookup_visibility, :work=),
        cpd: ServiceWrapper.new(Hyrax::Migrator::CpdCheck.new(File.join(work_dir, pidlist)), :check_cpd, :work=),
        edtf: ServiceWrapper.new(Hyrax::Migrator::EdtfCheck.new, :check_date_fields, :work=)
      }
    end

    def run(service_names)
      results = {}
      service_names.each do |sn|
        results[sn] = @members[sn].run
      end
      results
    end

    def reset(service_names, val)
      service_names.each do |sn|
        @members[sn].reset(val)
      end
    end

    # subclass to wrap the member service
    class ServiceWrapper
      def initialize(service_class, run_command, reset_property)
        @service_class = service_class
        @command = run_command
        @reset_property = reset_property
      end

      def run
        @service_class.send(@command)
      end

      def reset(val)
        @service_class.send(@reset_property, val)
      end
    end
  end
end
