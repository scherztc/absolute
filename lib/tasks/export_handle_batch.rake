namespace :export do

  desc 'Export a batch file suitable for updating handle.net handles for imported objects'
  task :modify_batch => :environment do
    require 'export/handles'
    exporter = Export::Handles.new('MODIFY', '2124', 'library.case.edu') # 2124 is the development namespace
    exporter.export!
  end

  desc 'Export a batch file suitable for registering handle.net handles for new objects'
  task :create_batch, [:pids] => :environment do |t, args|
    require 'export/handles'
    exporter = Export::Handles.new('CREATE', '2124', 'library.case.edu', [args.pids] + args.extras) # 2124 is the development namespace
    exporter.export!
  end
end
