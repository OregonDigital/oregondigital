desc 'Create and populate default thumbs directory'

task :default_thumbs_init => :environment do |t, args|
  FileUtils.mkdir_p APP_CONFIG['default_thumbs']['directory']
  FileUtils.cp('spec/fixtures/fixture_audio.jpg', File.join(APP_CONFIG['default_thumbs']['directory'], APP_CONFIG['default_thumbs']['audio_icon']))
  FileUtils.cp('spec/fixtures/fixture_cpd.jpg', File.join(APP_CONFIG['default_thumbs']['directory'], APP_CONFIG['default_thumbs']['cpd_icon']))
end

