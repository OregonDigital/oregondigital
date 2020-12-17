# frozen_string_literal:true

# Requires a work dir with copies of crosswalk, crosswalk_overrides, and required_fields yml files
# Also a list of pids in the work_dir, one pid per line
# Will write a report of any errors found to the work dir
# To use: rake preflight_tools:metadata_preflight work_dir=/data1/batch/some_dir pidlist=list.txt
# If verbose=true then the attributes will be displayed

require 'hyrax/migrator/preflight_check_services'

module Hyrax::Migrator
  # Intended to be run on OD1, reuses migrator code to perform pre-migration checks
  class PreflightChecks
    def initialize(work_dir, pidlist, verbose = false)
      @work_dir = work_dir
      @pidlist = pidlist
      @verbose = verbose
      @counters = { cpds: 0, visibility: 0 }
      @report = File.open(File.join(@work_dir, "report_#{Time.zone.now.strftime('%Y%m%d%H%M%S')}.txt"), 'w')
      @services = Hyrax::Migrator::PreflightCheckServices.new(files, work_dir, pidlist)
    end

    def verify
      File.foreach(File.join(@work_dir, @pidlist)).each do |pid|
        begin
          process(pid.strip)
        rescue StandardError => e
          @errors << "System error: #{e.message}"
        ensure
          write_errors
        end
      end
      close
    end

    def process(pid)
      @errors = ["Working on #{pid.strip}..."]
      work = GenericAsset.find(pid)
      @services.members[:status].reset(work)
      return unless status?

      @services.reset(%i[crosswalk visibility cpd], work)
      fetch_results
      verbose_display if @verbose
    end

    def fetch_results
      @results = @services.run(%i[crosswalk visibility cpd])
      concat_errors(@results[:crosswalk][:errors])
      run_required
      cpds?
      visibility?
    end

    def run_required
      @services.members[:required].reset(@results[:crosswalk])
      @results[:required] = @services.members[:required].run
      concat_errors(@results[:required])
    end

    def status?
      result = @services.members[:status].run
      return true if result == 'ok'

      concat_errors(result)
      verbose_display if @verbose
      false
    end

    def cpds?
      result = @results.delete :cpd
      @counters[:cpds] += 1 if result.include? 'cpd'
      concat_errors(result) if result.include? 'missing'
    end

    def visibility?
      result = @results.delete :visibility
      @counters[:visibility] += 1 unless result.value? 'open'
      concat_errors(result) if result.include? 'error'
    end

    def concat_errors(error)
      err = error.is_a?(Array) ? error : [error]
      @errors.concat err
    end

    def files
      { crosswalk_overrides: File.join(@work_dir, 'crosswalk_overrides.yml'),
        crosswalk: File.join(@work_dir, 'crosswalk.yml'),
        required_fields: File.join(@work_dir, 'required_fields.yml') }
    end

    def verbose_display
      @errors.each do |e|
        puts e
      end
    end

    def write_errors
      @errors.each do |e|
        @report.puts e
      end
    end

    def close
      @report.puts "CPD count: #{@counters[:cpds]}"
      @report.puts "Restricted items count: #{@counters[:visibility]}"
      @report.close
    end
  end
end
