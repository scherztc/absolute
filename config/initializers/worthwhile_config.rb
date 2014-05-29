Worthwhile.configure do |config|
  config.register_curation_concern :text
  config.register_curation_concern :image
  config.register_curation_concern :audio
  config.register_curation_concern :video
  config.register_curation_concern :case_generic_work
  
  # # You can override curate's antivirus runner by configuring a lambda (or
  # # object that responds to call)
  # config.default_antivirus_instance = lambda {|filename| … }

  # # Used for constructing permanent URLs
  # config.application_root_url = 'https://repository.higher.edu/'

  # # Override the file characterization runner that is used
  # config.characterization_runner = lambda {|filename| … }
end
