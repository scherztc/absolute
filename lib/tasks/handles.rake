namespace :handles do

  desc 'Update each of the identifiers to contain either a handle.net link or a DOI'
  task :update => :environment do |t, args|
    require 'handles/update'
    updater = Handles::Update.new
    updater.update!
  end
end
