Curate.configure do |config|
  # Injected via `rails g curate:work Text`
  config.register_curation_concern :text
  config.register_curation_concern :image
  config.register_curation_concern :case_generic_work
  
  # # You can override curate's antivirus runner by configuring a lambda (or
  # # object that responds to call)
  # config.default_antivirus_instance = lambda {|filename| … }

  # # Used for constructing permanent URLs
  # config.application_root_url = 'https://repository.higher.edu/'

  # # Override the file characterization runner that is used
  # config.characterization_runner = lambda {|filename| … }
end

#  TODO: Patch Curate to rely on a value you set in Curate.configure rather than necessitating this mess.
#  This tells curate which types of works to show in the list of options in the "quick add" dropdown
#  The relevant partial is app/views/shared/_add_content.html.erb, which calls
#     QuickClassificationQuery.each_for_context(current_user)
QuickClassificationQuery::CURATION_CONCERNS_TO_TRY = ['text', 'image']