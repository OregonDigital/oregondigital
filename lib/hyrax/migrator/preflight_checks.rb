# frozen_string_literal:true

# Requires a work dir with copies of crosswalk, crosswalk_overrides, and required_fields yml files
# Also a list of pids in the work_dir, one pid per line
# Will write a report of any errors found to the work dir
# To use: rake preflight_tools:metadata_preflight work_dir=/data1/batch/some_dir pidlist=list.txt

require 'hyrax/migrator/preflight_check_services'

module Hyrax::Migrator
  # Intended to be run on OD1, reuses migrator code to perform pre-migration checks
  class PreflightChecks
    def initialize(work_dir, pidlist)
      @work_dir = work_dir
      @pidlist = pidlist
      @counters = { cpds: 0, visibility: 0 }
      @error_count = { crosswalk: 0, visibility: 0, status: 0, edtf: 0, required: 0, cpd: 0 }
      @report = File.open(File.join(@work_dir, "#{batchname}_report_#{Time.zone.now.strftime('%Y%m%d%H%M%S')}.txt"), 'w')
      @services = Hyrax::Migrator::PreflightCheckServices.new(files, work_dir, pidlist)
    end

    def verify
      File.foreach(File.join(@work_dir, @pidlist)).each do |pid|
        begin
          process(pid.strip)
        rescue StandardError => e
          @errors << "System error: #{e.message}"
        ensure
          write_errors(pid.strip)
        end
      end
      close
    end

    def process(pid)
      @errors = ['...']
      work = GenericAsset.find(pid)
      @services.members[:status].reset(work)
      return unless status?

      @services.reset(%i[crosswalk visibility cpd edtf], work)
      fetch_results
    end

    def fetch_results
      @results = @services.run(%i[crosswalk visibility cpd edtf])
      concat_errors(@results[:crosswalk][:errors])
      count_errors(:crosswalk, @results[:crosswalk][:errors])
      run_required
      cpds?
      visibility?
      edtf?
    end

    def run_required
      @services.members[:required].reset(@results[:crosswalk])
      @results[:required] = @services.members[:required].run
      concat_errors(@results[:required])
      count_errors(:required, @results[:required])
    end

    def status?
      result = @services.members[:status].run
      return true if result == 'ok'

      concat_errors(result)
      count_errors(:status, result)
      false
    end

    def cpds?
      result = @results.delete :cpd
      @counters[:cpds] += 1 if result.include? 'cpd'
      return unless result.include? 'missing'

      concat_errors(result)
      count_errors(:cpd, result)
    end

    def visibility?
      result = @results.delete :visibility
      @counters[:visibility] += 1 unless result.value? 'open'
      return unless result.include? 'error'

      concat_errors(result)
      count_errors(:visibility, result)
    end

    def edtf?
      result = @results.delete :edtf
      return if result.empty?

      concat_errors(result)
      count_errors(:edtf, result)
    end

    def concat_errors(error)
      err = error.is_a?(Array) ? error : [error]
      @errors.concat err
    end

    def count_errors(service, error)
      count = error.is_a?(Array) ? error.size : 1
      @error_count[service] += count
    end

    def files
      { crosswalk_overrides: File.join(@work_dir, 'crosswalk_overrides.yml'),
        crosswalk: File.join(@work_dir, 'crosswalk.yml'),
        required_fields: File.join(@work_dir, 'required_fields.yml') }
    end

    def write_errors(pid)
      @errors.each do |e|
        @report.puts "#{pid}\t#{e}"
      end
    end

    def close
      @report.puts "CPD count: #{@counters[:cpds]}"
      @report.puts "Restricted items count: #{@counters[:visibility]}"
      @report.puts 'Errors: '
      @error_count.each do |k, v|
        @report.puts "  #{k}: #{v}"
      end
      @report.close
    end

    def batchname
      File.basename(@pidlist, '.*').split('_pid').first
    end
  end
end
