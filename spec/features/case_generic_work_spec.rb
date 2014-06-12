require 'spec_helper'

describe 'Creating a Case generic work' do
  let(:user) { FactoryGirl.create(:admin) }

  describe 'with a related link' do
    it "should allow me to attach the link on the create page" do
      login_as(user)
      visit root_path
      click_link "add-content"
      classify_what_you_are_uploading 'Case Generic Work'
      within '#new_case_generic_work' do
        fill_in "Title", with: "My title"
        fill_in "External link", with: "http://www.youtube.com/watch?v=oHg5SJYRHA0"
        select(Sufia.config.cc_licenses.first.dup, from: I18n.translate('sufia.field_label.rights'))
        check("I have read and accept the contributor license agreement")
        click_button("Create Case generic work")
      end

      expect(page).to have_selector('h1', text: 'Other')
      within ('.linked_resource.attributes') do
        expect(page).to have_link('http://www.youtube.com/watch?v=oHg5SJYRHA0', href: 'http://www.youtube.com/watch?v=oHg5SJYRHA0')
      end
    end
  end
end

describe 'Editing a generic work owned by the user' do
  let(:user) { FactoryGirl.create(:user) }
  let(:work) { FactoryGirl.create(:case_generic_work, user: user) }
  let(:you_tube_link) { 'http://www.youtube.com/watch?v=oHg5SJYRHA0' }

  it 'should allow me to attach a linked resource' do
    login_as(user)
    visit curation_concern_case_generic_work_path(work)
    click_link 'Add an External Link'

    within '#new_linked_resource' do
      fill_in 'External link', with: you_tube_link
      click_button 'Add External Link'
    end

    within ('.linked_resource.attributes') do
      expect(page).to have_link(you_tube_link, href: you_tube_link)
    end
  end
end

describe 'Viewing a Case generic work I don\'t own' do
  let(:user) { FactoryGirl.create(:user) }

  context 'and I don\'t have permission to see' do
    let(:work) { FactoryGirl.create(:private_case_generic_work, title: "Sample work", description:"My favorite thing." ) }
    it 'should show a stub indicating we have the work, but it is private' do
      login_as(user)
      visit curation_concern_case_generic_work_path(work)
      expect(page).to have_content('Unauthorized')
      expect(page).to have_content('The other you have tried to access is private')
      expect(page).to have_content("ID: #{work.pid}")
      expect(page).to_not have_content("Sample work")
    end
  end

  context 'but I do have permission to see' do
    let(:work) { FactoryGirl.create(:public_case_generic_work, title: "Sample work", description:"My favorite thing." ) }
    before do
      login_as(user)
    end
    it 'should show me the work' do
      visit curation_concern_case_generic_work_path(work)
      expect(page).to_not have_content('Unauthorized')
      expect(page).to have_content("Sample work")
      expect(page).to have_content("My favorite thing")
      expect(page).to have_content("XML Metadata Attachments")

    end
    it 'should not show me the file uploader' do
      visit curation_concern_case_generic_work_path(work)
      expect(page).to_not have_content("upload")
      expect(page).to_not have_content("Select files")
    end
  end
end
