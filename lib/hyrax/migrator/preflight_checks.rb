# frozen_string_literal:true

# Requires a work dir with copies of crosswalk, crosswalk_overrides, and required_fields yml files
# Also a list of pids in the work_dir, one pid per line
# Will write a report of any errors found to the work dir
# To use: rake preflight_tools:metadata_preflight work_dir=/data1/batch/some_dir pidlist=list.txt
# If verbose=true then the attributes will be displayed
require 'hyrax/migrator/crosswalk_metadata_preflight'
require 'hyrax/migrator/required_fields'
require 'hyrax/migrator/asset_status'
require 'hyrax/migrator/visibility_lookup_preflight'

module Hyrax::Migrator
  # Intended to be run on OD1, reuses migrator code to perform pre-migration checks
  class PreflightChecks
    def initialize(work_dir, pidlist, verbose = false)
      @work_dir = work_dir
      @pidlist = pidlist
      @verbose = verbose
      @counters = init_counters
      init_continue
    end

    def init_continue
      datetime_today = Time.zone.now.strftime('%Y%m%d%H%M%S') # "20171021125903"
      @report = File.open(File.join(@work_dir, "report_#{datetime_today}.txt"), 'w')
      @crosswalk_service = Hyrax::Migrator::CrosswalkMetadataPreflight.new(crosswalk_file, crosswalk_overrides_file)
      @required_service = Hyrax::Migrator::RequiredFields.new(required_fields_file)
      @status_service = Hyrax::Migrator::AssetStatus.new
      @visibility_service = Hyrax::Migrator::VisibilityLookupPreflight.new
      @cpd_service = Hyrax::Migrator::CpdCheck.new(File.join(@work_dir, @pidlist))
      @errors = []
    end

    def init_counters
      counters = {}
      counters[:cpds] = 0
      counters
    end

    def verify
      pids.each do |pid|
        begin
          @errors << "Working on #{pid}..."
          process(pid)
        rescue StandardError => e
          @errors << "System error: #{e.message}"
        end
      end
      write_errors
      @report.close
    end

    def pids
      pids = []
      File.readlines(File.join(@work_dir, @pidlist)).each do |line|
        pids << line.strip
      end
      pids
    end

    def process(pid)
      work = GenericAsset.find(pid)
      reset_status(work)
      return unless status(@status_service.verify_status)

      process_continue(work)
    end

    def process_continue(work)
      reset_crosswalk(work)
      crosswalk_result = @crosswalk_service.crosswalk
      reset_required(crosswalk_result)
      required_result = @required_service.verify_fields
      reset_visibility(work)
      visibility_result = @visibility_service.lookup_visibility
      reset_cpd_check(work)
      cpd_result = @cpd_service.check_cpd
      bump_counters(visibility_result, cpd_result)
      concat_errors([crosswalk_result[:errors], required_result, [visibility_result], [cpd_result])
      verbose_display(work.pid, crosswalk_result.except(:errors)) if @verbose
    end

    def status(result)
      return true if result == 'ok'

      concat_errors([[result]])
      false
    end

    def bump_counters(cpd)
      counters[:cpds] +=1 if cpd.include? 'cpd'
    end

    def concat_errors(errors)
      errors.each do |errs|
        @errors.concat errs unless errs.blank?
      end
    end

    def reset_crosswalk(work)
      @crosswalk_service.graph = create_graph(work)
      @crosswalk_service.errors = []
      @crosswalk_service.result = {}
    end

    def reset_required(attributes)
      @required_service.attributes = attributes
    end

    def reset_status(work)
      @status_service.work = work
    end

    def reset_visibility(work)
      @visibility_service.work = work
    end

    def reset_cpd_check(work)
      @cpd_service.work = work
    end

    def crosswalk_overrides_file
      File.join(@work_dir, 'crosswalk_overrides.yml')
    end

    def crosswalk_file
      File.join(@work_dir, 'crosswalk.yml')
    end

    def required_fields_file
      File.join(@work_dir, 'required_fields.yml')
    end

    def create_graph(item)
      item.datastreams['descMetadata'].graph
    end

    def verbose_display(pid, attributes)
      puts "Attributes for #{pid}..."
      attributes.each do |attr|
        puts attr.to_s
      end
    end

    def write_errors
      @report.puts "CPD count: #{@counters[:cpds]}"
      @errors.each do |e|
        @report.puts e
      end
    end
  end
end
