namespace :export do

  desc 'Export a batch file suitable for registering handle.net handles for objects'
  task :handles, => :environment do |t, args|
    require 'export/handles'
    exporter = Export::Handles.new('2124') # 2124 is the development namespace
    exporter.export!
  end
end
