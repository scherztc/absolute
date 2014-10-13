task :ci => [:jetty, 'jetty:config'] do
  jetty_params = Jettywrapper.load_config
  jetty_params[:startup_wait] = 60
  Jettywrapper.wrap(jetty_params) do
    Rake::Task['spec'].invoke
  end
end

task :jetty do
  unless File.exist?('jetty')
    puts "Downloading jetty"
    `rails generate hydra:jetty`
  end
end

