require 'yaml'
config = YAML.load_file('config/app.yml')["deployment"] || {}

require 'bundler/capistrano'
require 'new_relic/recipes'

set :stages, config['stages'] || []
set :default_stage, config['default_stage'] || (config['stages'] || []).first
require 'capistrano/ext/multistage'

set :application, 'OregonDigital'
set :repository, config['repository']
set :user, config['user']
set :default_environment, config['default_environment'] || {}
default_run_options[:pty] = true
set :scm, :git
set :branch, config['branch']
set :deploy_via, :remote_cache
set :use_sudo, false
set :keep_releases, 5
set :shared_children, shared_children + %w{pids sockets tmp media set_content public/media public/thumbnails jetty}

# if you want to clean up old releases on each deploy uncomment this:
after 'deploy:restart', 'deploy:cleanup'

after 'deploy:finalize_update', 'deploy:symlink_config'
after 'deploy:update_code', 'deploy:migrate'
before 'deploy:assets:precompile', 'sets:sync'
after 'deploy:restart', 'deploy:cleanup'

after "deploy:update", "newrelic:notice_deployment"

namespace :deploy do
  desc "Symlinks required configuration files"
  task :symlink_config, :roles => :app do
    %w{app.yml god.conf puma.rb}.each do |config_file|
      run "ln -nfs #{deploy_to}/shared/config/#{config_file} #{release_path}/config/#{config_file}"
    end
  end
end
namespace :sets do
  desc "Updates Collection Pages"
  task :sync, :roles => :app do
    rake = fetch(:rake, "rake")
    rails_env = fetch(:rails_env, "production")
    run "cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} sets:content:sync"
  end
end
namespace :rails do
  desc "Opens up a rails console"
  task :console, :roles => :app do
    hostname = find_servers_for_task(current_task).first
    exec "ssh -l #{user} #{hostname} -t 'source ~/.bash_profile && cd #{deploy_to}/current && export RBENV_VERSION=#{config[rails_env.to_s]['default_environment']['RBENV_VERSION']} && RAILS_ENV=#{rails_env} bundle exec rails c'"
  end
end
