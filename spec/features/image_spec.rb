require 'spec_helper'

describe 'Creating a Image' do
  let(:user) { FactoryGirl.create(:admin) }

  describe 'with a related link' do
    it "should allow me to attach the link on the create page" do
      login_as(user)
      visit root_path
      click_link "add-content"
      classify_what_you_are_uploading 'Image'
      within '#new_image' do
        fill_in "Title", with: "My title"
        fill_in "External link", with: "http://www.youtube.com/watch?v=oHg5SJYRHA0"
        select(Sufia.config.cc_licenses.keys.first.dup, from: I18n.translate('sufia.field_label.rights'))
        check("I have read and accept the contributor license agreement")
        click_button("Create Image")
      end

      expect(page).to have_selector('h1', text: 'Image')
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
      classify_what_you_are_uploading 'Image'
      within '#new_image' do
        fill_in "Title", with: "My title"
        attach_file "Choose a VRA file", fixture_file_path('files/wrhsglePos-48-VRA.xml')
        attach_file "Choose a MODS file", fixture_file_path('files/anoabo00-MODS.xml')
        select(Sufia.config.cc_licenses.keys.first.dup, from: I18n.translate('sufia.field_label.rights'))
        check("I have read and accept the contributor license agreement")
        click_button("Create Image")
      end
      expect(page).to have_selector('h1', text: 'Image')
      within ('.attachment.attributes.vra') do
        expect(page).to have_link('VRA')
      end
      within ('.attachment.attributes.mods') do
        expect(page).to have_link('MODS')
      end
    end
  end
end

describe 'An existing Image owned by the user' do
  let(:user) { FactoryGirl.create(:user) }
  let(:work) { FactoryGirl.create(:image, user: user) }
  let(:you_tube_link) { 'http://www.youtube.com/watch?v=oHg5SJYRHA0' }

  it 'should allow me to attach a linked resource' do
    pending "[linked_resource] until we decide what the UX is for adding linked resources."
    login_as(user)
    visit curation_concern_case_generic_work_path(work)
    save_and_open_page
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
    visit curation_concern_image_path(work)
    click_link 'Add an External Link'
    page.should have_link('Cancel', href: catalog_index_path)
  end
end

describe 'Viewing a Image that is private' do
  let(:user) { FactoryGirl.create(:user) }
  let(:work) { FactoryGirl.create(:private_case_generic_work, title: "Sample work" ) }

  it 'should show a stub indicating we have the work, but it is private' do
    login_as(user)
    visit curation_concern_image_path(work)
    page.should have_content('Unauthorized')
    page.should have_content('The image you have tried to access is private')
    page.should have_content("ID: #{work.pid}")
    page.should_not have_content("Sample work")
  end
end