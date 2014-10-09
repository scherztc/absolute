set :application, 'absolute'
set :repo_url, 'git@github.com:KelvinSmithLibrary/absolute.git'
set :branch, 'master'

# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

set :deploy_to, '/opt/absolute'
set :scm, :git

# set :format, :pretty
set :log_level, :debug
# set :pty, true

set :assets_prefix, "#{shared_path}/public/assets"

set :linked_files, %w{config/database.yml config/devise.yml config/fedora.yml config/recipients_list.yml config/redis.yml config/resque-pool.yml config/solr.yml config/initializers/secret_token.rb log/resque-pool.stderr.log log/resque-pool.stdout.log}

set :linked_dirs, %w{tmp/pids tmp/cache tmp/sockets public/assets log/imports}

# set :default_env, { path: "/opt/ruby/bin:$PATH" }
# set :keep_releases, 5

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), 'deploy')

require "resque"
namespace :deploy do

  desc 'Restart application'
  after :publishing, :restart
  
  task :restart do
    on roles(:web), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      execute "touch #{release_path}/tmp/restart.txt"
    end
  end

  after :restart, 'resque:pool:restart'
  after :restart, 'resque:scheduler:restart'

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

  after :finishing, 'deploy:cleanup'

end
