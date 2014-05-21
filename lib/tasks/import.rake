namespace :import do

  desc 'Import records from another fedora'
  task :pids, [:fedora_env] => :environment  do |t, args|
    require 'import/object_importer'
    importer = ObjectImporter.new(args.fedora_env, args.extras, true)
    importer.import!
  end

end
