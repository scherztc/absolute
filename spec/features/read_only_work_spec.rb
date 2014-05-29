require 'spec_helper'

describe 'Viewing a Case generic work I don\'t own' do
  let(:user) { FactoryGirl.create(:user) }

  describe 'but I do have permission to see' do
    let(:work) { FactoryGirl.create(:public_case_generic_work, title: "Sample work", description:"My favorite thing." ) }
    before do
      login_as(user)
    end
    it 'should show me the work' do
      visit curation_concern_case_generic_work_path(work)
      page.should_not have_content('Unauthorized')
      page.should have_content("Sample work")
      page.should have_content("My favorite thing")
      page.should have_content("XML Metadata Attachments")
    end
    it 'should not show me the file uploader' do
      visit curation_concern_case_generic_work_path(work)
      page.should_not have_content('upload')
      page.should_not have_content('Select files')
    end
  end

  describe 'and I don\'t have permission to see' do
    let(:work) { FactoryGirl.create(:private_case_generic_work, title: "Sample work", description:"My favorite thing." ) }
    it 'it should show a stub indicating we have the work, but it is private' do
      login_as(user)
      visit curation_concern_case_generic_work_path(work)
      page.should have_content('Unauthorized')
      page.should have_content('The other you have tried to access is private')
      page.should have_content("ID: #{work.pid}")
      page.should_not have_content("Sample work")
    end
  end
end
