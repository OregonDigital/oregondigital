# frozen_string_literal:true

# Requires a work dir with copies of crosswalk, crosswalk_overrides, and required_fields yml files
# Also a list of pids in the work_dir, one pid per line
# Will write a report of any errors found to the work dir
# To use: rake preflight_tools:preflight work_dir=/data1/batch/some_dir pidlist=list.txt
# If verbose=true then the attributes will be displayed

namespace :preflight_tools do
  task preflight: :environment do
    require 'hyrax/migrator/preflight_checks'
    init
    @service.verify
  end
end

def init
  @work_dir = ENV['work_dir']
  @pidlist = ENV['pidlist']
  @service = Hyrax::Migrator::PreflightChecks.new(@work_dir, @pidlist, ENV['verbose'])
end
