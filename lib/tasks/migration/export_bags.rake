# frozen_string_literal: true

require 'bagit'

# Usage:
#
# task export_bags
# args
#   export_dir:
#     base directory for exported bags
#   name:
#     name of the batch (a directory with this name will be added to export_dir)
#   pidlist:
#     path to the pidlist txt file (one pid per line) expected within export_dir
#
# task export_bags creates a folder with {name} for datastreams, makes bags
# based on this folder, and then adds them in {name}_bags folder also inside export_dir
#
# example:
#
# RAILS_ENV=production bundle exec rake export_bags export_dir=/data1/batch/exports name='baseball' pidlist=pidlist.txt verbose=true
#
desc 'Export bags given an export path, a batch name, and a pidlist text file'
namespace :migration do
  task export_bags: :environment do
    require 'hyrax/migrator/export'
    export_dir = ENV['export_dir']
    name = ENV['name']
    pidlist = ENV['pidlist']
    service = Hyrax::Migrator::Export.new(export_dir, name, pidlist, ENV['verbose'])
    service.export
  end
end
