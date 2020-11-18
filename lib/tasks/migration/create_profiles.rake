# For use as part of verification process in migrating assets from oregondigital
# Requires a list of pids, one pid per line
# to call: bundle exec rake create_profiles pids=/data1/batch/profiles/pidlist.txt export_path=/data1/batch/profiles

desc 'Create asset profile yml file' 
task create_profiles: :environment do
  require 'hyrax/migrator/metadata_profiler'
  include Hyrax::Migrator::MetadataProfiler

  export_path = ENV['export_path']
  pidlist.each do |pid|
    item = GenericAsset.find(pid)
    create_profile(export_path, item)
  end
rescue StandardError => e
  puts e.message
  puts e.backtrace.join("\n")
end

def pidlist
  arr = []
  File.readlines(ENV['pids']).each do |line|
    arr << line.strip
  end
  arr
end
