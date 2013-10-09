PATH = Rails.root.to_s
REPO_PATH = "#{PATH}/set_content"
GITFILE = "#{REPO_PATH}/.git"
ASSET_PATH = Rails.root.join("app/assets").to_s
SET_JS_PATH = ASSET_PATH + "/javascripts/sets"
SET_IMG_PATH = ASSET_PATH + "/images/sets"
SET_CSS_PATH = ASSET_PATH + "/stylesheets/sets"
SET_CONTENT_PATH = PATH + "/app/views/sets"

namespace :sets do
  namespace :content do
    directory SET_JS_PATH
    directory SET_IMG_PATH
    directory SET_CSS_PATH
    directory SET_CONTENT_PATH

    # Create the git repo if it's not already around
    file GITFILE do
      sh "git clone #{APP_CONFIG.set_content_repo} #{REPO_PATH}"
    end

    desc 'Sync to the latest version of set-specific content and assets'
    task :sync => [:environment, GITFILE, :clean_links] do
      # Grab the latest version of the repo
      sh "cd #{REPO_PATH} && git pull origin master"

      Dir["#{REPO_PATH}/*"].each do |set_repo_path|
        next unless File.directory?(set_repo_path)
        next if set_repo_path =~ /^\./

        setname = File.basename(set_repo_path)

        dir = set_repo_path + "/content"
        sh "ln -s #{dir} #{SET_CONTENT_PATH}/#{setname}" if File.directory?(dir)

        dir = set_repo_path + "/assets/javascripts"
        sh "ln -s #{dir} #{SET_JS_PATH}/#{setname}" if File.directory?(dir)

        dir = set_repo_path + "/assets/images"
        sh "ln -s #{dir} #{SET_IMG_PATH}/#{setname}" if File.directory?(dir)

        dir = set_repo_path + "/assets/stylesheets"
        sh "ln -s #{dir} #{SET_CSS_PATH}/#{setname}" if File.directory?(dir)
      end

      if Rails.env.production?
        # Invoke asset compilation task
        Rake::Task["assets:precompile"]

        # Ask Rails to restart
        sh "touch #{PATH}/tmp/restart.txt"
      end
    end

    desc "Clean all asset symlinks without removing the git repository"
    task :clean_links => [SET_JS_PATH, SET_IMG_PATH, SET_CSS_PATH, SET_CONTENT_PATH] do
      sh "find #{SET_JS_PATH} -type l -exec rm {} \\;"
      sh "find #{SET_CSS_PATH} -type l -exec rm {} \\;"
      sh "find #{SET_IMG_PATH} -type l -exec rm {} \\;"
      sh "find #{SET_CONTENT_PATH} -type l -exec rm {} \\;"
    end

    desc "Clean all set-specific assets, including the repository"
    task :clean => [:environment, :clean_links] do
      sh "rm -rf #{REPO_PATH}"
    end
  end
end
