config = YAML.load_file('config/app.yml')["deployment"]["production"] || {}

set :user, config['user']
# Set RBEnv Stuff
set :default_environment, config['default_environment'] || {}
# Servers
role :web, config['hosts']['web'] # Your HTTP server, Apache/etc
role :app, config['hosts']['app'] # This may be the same as your `Web` server
role :db,  config['hosts']['db'], :primary => true # This is where Rails migrations will run
# Git Config
set :branch, config['branch']
# God Settings
set(:god_app_path) {"#{current_path}/#{config['god']['app_path']}"}
set :god_sites_path,  config['god']['sites_path']
set :deploy_to, config['deploy_to']
# Deploy Commands
# Override deploy to inform god to do the restarts.
namespace :deploy do
  task :start do
    god.start
  end
  task :stop do
    god.stop
  end
  task :restart do
    god.restart
  end
end

namespace :god do
  desc "Reload god config"
  task :reload, :roles => :app, :except => {:no_release => true} do
    run "ln -nfs #{god_app_path} #{god_sites_path}/#{application}.conf"
    sudo "/etc/init.d/god restart"
  end

  task :restart, :roles => :app, :except => {:no_release => true} do
    run "touch #{shared_path}/tmp/restart.txt && touch #{shared_path}/tmp/restart-faye.txt && touch #{shared_path}/tmp/restart-sidekiq.txt"
  end

  task :start, :roles => :app do
    sudo "/etc/init.d/god startapp #{application}"
  end

  task :stop, :roles => :app do
    sudo "/etc/init.d/god stopapp #{application}"
  end
  task :status, :roles => :app do
    sudo "/etc/init.d/god status #{applictaion}"
  end
end
