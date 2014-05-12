require 'spec_helper'

describe 'Creating a Text' do
  let(:user) { FactoryGirl.create(:user) }
  # let(:tei_file_path) { fixture_path('files/anoabo00-TEI.xml') }

  describe 'with a related link' do
    it "should allow me to attach the link on the create page" do
      login_as(user)
      visit root_path
      click_link "add-content"
      classify_what_you_are_uploading 'Text'
      within '#new_text' do
        fill_in "Title", with: "My title"
        fill_in "External link", with: "http://www.youtube.com/watch?v=oHg5SJYRHA0"
        select(Sufia.config.cc_licenses.keys.first.dup, from: I18n.translate('sufia.field_label.rights'))
        check("I have read and accept the contributor license agreement")
        click_button("Create Text")
      end

      expect(page).to have_selector('h1', text: 'Text')
      within ('.linked_resource.attributes') do
        expect(page).to have_link('http://www.youtube.com/watch?v=oHg5SJYRHA0', href: 'http://www.youtube.com/watch?v=oHg5SJYRHA0')
      end
    end
  end
  
  describe 'with attached XML' do
    it "should allow me to attach the XML on create page" do
      login_as(user)
      visit root_path
      click_link "add-content"
      classify_what_you_are_uploading 'Text'
      within '#new_text' do
        fill_in "Title", with: "My title"
        attach_file "Choose a TEI file", fixture_file_path('files/anoabo00-TEI.xml')
        attach_file "Choose a MODS file", fixture_file_path('files/anoabo00-MODS.xml')
        select(Sufia.config.cc_licenses.keys.first.dup, from: I18n.translate('sufia.field_label.rights'))
        check("I have read and accept the contributor license agreement")
        click_button("Create Text")
      end

      expect(page).to have_selector('h1', text: 'Text')
      within ('.attachment.attributes.tei') do
        expect(page).to have_link('TEI')
      end
      within ('.attachment.attributes.teip5') do
        expect(page).to have_text('TEIP5')
        expect(page).not_to have_link('TEIP5')
      end
      within ('.attachment.attributes.mods') do
        expect(page).to have_link('MODS')
      end
    end
  end
end

describe 'An existing Text owned by the user' do
  let(:user) { FactoryGirl.create(:user) }
  let(:work) { FactoryGirl.create(:text, user: user) }
  let(:you_tube_link) { 'http://www.youtube.com/watch?v=oHg5SJYRHA0' }

  it 'should allow me to attach a linked resource' do
    pending "[linked_resource] until we decide what the UX is for adding linked resources."
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

  it 'cancel takes me back to the dashboard' do
    pending "[linked_resource] until we decide what the UX is for adding linked resources."
    login_as(user)
    visit curation_concern_text_path(work)
    click_link 'Add an External Link'
    page.should have_link('Cancel', href: catalog_index_path)
  end
end

describe 'Viewing a Text that is private' do
  let(:user) { FactoryGirl.create(:user) }
  let(:work) { FactoryGirl.create(:text, title: "Sample work" ) }

  it 'should show a stub indicating we have the work, but it is private' do
    login_as(user)
    visit curation_concern_text_path(work)
    page.should have_content('Unauthorized')
    page.should have_content('The text you have tried to access is private')
    page.should have_content("ID: #{work.pid}")
    page.should_not have_content("Sample work")
  end
end