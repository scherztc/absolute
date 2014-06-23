namespace :load do
  namespace :defaults do
    set :resque_stderr_log, "#{shared_path}/log/resque-pool.stderr.log"
    set :resque_stdout_log, "#{shared_path}/log/resque-pool.stdout.log"
    set :resque_kill_signal, "QUIT"
    
  end
end

namespace :resque do
  namespace :pool do
    desc "Stop resque pool"
    task :stop do
      on roles(:resque_worker), in: :sequence, wait: 5 do
        # Shuts down resque_pool master if pid exists
        if test("[ -f #{shared_path}/tmp/pids/resque-pool.pid ]")
          execute "export master_pid=$(cat #{shared_path}/tmp/pids/resque-pool.pid) && kill -QUIT $master_pid"
        else
          warn "No resque-pool pid found"
        end
      end
    end

    desc "Start resque pool"
    task :start do
      on roles(:resque_worker), in: :sequence, wait: 5 do
        # Starts a new resque_pool master
        
        execute "cd #{release_path} && bundle exec resque-pool -d -E #{fetch(:rails_env)} -c config/resque-pool.yml -p #{shared_path}/tmp/pids/resque-pool.pid -e #{fetch(:resque_stderr_log)} -o #{fetch(:resque_stdout_log)}"
      end
    end

    desc "Restart resque pool"
    task :restart do
      invoke "resque:pool:stop"
      invoke "resque:pool:start"
    end
  end

  # From https://github.com/sshingler/capistrano-resque/blob/master/lib/capistrano-resque/tasks/capistrano-resque.rake
  def output_redirection
    ">> #{fetch(:resque_stdout_log)} 2>> #{fetch(:resque_stderr_log)}"
  end

  namespace :scheduler do
    desc "See current scheduler status"
    task :status do
      on roles :resque_scheduler do
        pid = "#{shared_path}/tmp/pids/scheduler.pid"
        if test "[ -e #{pid} ]"
          info capture(:ps, "-f -p $(cat #{pid}) | sed -n 2p")
        end
      end
    end

    desc "Starts resque scheduler with default configs"
    task :start do
      on roles :resque_scheduler do
        pid = "#{shared_path}/tmp/pids/scheduler.pid"
        within current_path do
          execute :rake, %{RAILS_ENV=#{fetch(:rails_env)} PIDFILE=#{pid} BACKGROUND=yes VERBOSE=1 MUTE=1 resque:scheduler #{output_redirection}}
        end
      end
    end

    desc "Stops resque scheduler"
    task :stop do
      on roles :resque_scheduler do
        pid = "#{shared_path}/tmp/pids/scheduler.pid"
        if test "[ -e #{pid} ]"
          execute :kill, "-s #{fetch(:resque_kill_signal)} $(cat #{pid}); rm #{pid}"
        end
      end
    end

    task :restart do
      invoke "resque:scheduler:stop"
      invoke "resque:scheduler:start"
    end
  end
end

