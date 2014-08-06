namespace :export do

  desc 'Export a batch file suitable for registering handle.net handles for the objects'
  task :handle_batch => :environment do
    require 'export/handles'
    exporter = Export::Handles.new('2124', 'library.case.edu') # 2124 is the development namespace
    exporter.export!
  end
end
