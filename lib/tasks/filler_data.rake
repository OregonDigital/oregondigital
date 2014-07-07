desc 'Populates Fedora with filler data for development'

task :filler_data => :environment do |t, args|
  OregonDigital::FillerDataBuilder.call
end

