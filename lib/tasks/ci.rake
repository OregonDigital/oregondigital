# CI Task from Sufia [https://github.com/projecthydra/sufia/blob/master/tasks/sufia-dev.rake]

APP_ROOT="." # for jettywrapper
require 'jettywrapper'

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