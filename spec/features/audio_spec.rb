require 'spec_helper'

describe 'Creating a Audio' do
  let(:user) { FactoryGirl.create(:admin) }
  # let(:tei_file_path) { fixture_path('files/anoabo00-TEI.xml') }

  describe 'with a related link' do
    it "should allow me to attach the link on the create page" do
      login_as(user)
      visit root_path
      click_link "add-content"
      classify_what_you_are_uploading 'Audio'
      within '#new_audio' do
        fill_in "Title", with: "My title"
        fill_in "External link", with: "http://www.youtube.com/watch?v=oHg5SJYRHA0"
        select(Sufia.config.cc_licenses.first.dup, from: I18n.translate('sufia.field_label.rights'))
        check("I have read and accept the contributor license agreement")
        click_button("Create Audio")
      end

      expect(page).to have_selector('h1', text: 'Audio')
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
      classify_what_you_are_uploading 'Audio'
      within '#new_audio' do
        fill_in "Title", with: "My title"
        attach_file "Choose a PBCore file", fixture_file_path('files/wrhsglePos-48-VRA.xml')
        attach_file "Choose a MODS file", fixture_file_path('files/anoabo00-MODS.xml')
        select(Sufia.config.cc_licenses.first.dup, from: I18n.translate('sufia.field_label.rights'))
        check("I have read and accept the contributor license agreement")
        click_button("Create Audio")
      end
      expect(page).to have_selector('h1', text: 'Audio')
      within ('.attachment.attributes.pbcore') do
        expect(page).to have_link('PBCore')
      end
      within ('.attachment.attributes.mods') do
        expect(page).to have_link('MODS')
      end
    end
  end
end

describe 'An existing Audio owned by the user' do
  let(:user) { FactoryGirl.create(:user) }
  let(:work) { FactoryGirl.create(:audio, user: user) }
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

describe 'Viewing a Audio that is private' do
  let(:user) { FactoryGirl.create(:user) }
  let(:work) { FactoryGirl.create(:private_case_generic_work, title: "Sample work" ) }

  it 'should show a stub indicating we have the work, but it is private' do
    login_as(user)
    visit curation_concern_audio_path(work)
    expect(page).to have_content('Unauthorized')
    expect(page).to have_content('The audio you have tried to access is private')
    expect(page).to have_content("ID: #{work.pid}")
    expect(page).to_not have_content("Sample work")
  end
end
