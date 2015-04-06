# CI Task from Sufia [https://github.com/projecthydra/sufia/blob/master/tasks/sufia-dev.rake]

APP_ROOT="." # for jettywrapper
require 'jettywrapper'
require 'rspec/core'
require 'rspec/core/rake_task'

desc 'Spin up hydra-jetty and run specs'
task :ci => ['jetty:config'] do
  puts 'running continuous integration'
  jetty_params = Jettywrapper.load_config
  error = Jettywrapper.wrap(jetty_params) do
    Rake::Task['db:migrate'].invoke
    Rake::Task['db:test:prepare'].invoke
    Rake::Task['sets:content:sync'].invoke
    Rake::Task['spec'].invoke
  end
  raise "test failures: #{error}" if error
end

desc 'Circle CI Spec Runner'
task :circle_ci => :environment do
  Jettywrapper.configure(Jettywrapper.load_config)
  Jettywrapper.instance.startup_wait!
  RSpec::Core::RakeTask.new(:ci_spec) do |t|
    t.rspec_opts = "--format progress --color --format RspecJunitFormatter --out #{ENV['CIRCLE_TEST_REPORTS'] || Rails.root}/rspec/rspec.xml"
  end
  Rake::Task["ci_spec"].invoke
end
