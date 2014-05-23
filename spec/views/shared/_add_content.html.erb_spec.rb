require 'spec_helper'

describe 'shared/_add_content.html.erb' do

  context "for admins" do
    it 'has links to edit and add to collections' do
      allow(view).to receive(:current_user).and_return(FactoryGirl.create(:admin))
      allow(view).to receive(:can?).and_return(true)
      render partial: 'shared/add_content'
      expect(rendered).to have_link("Roles", href: role_management.roles_path)
      Worthwhile.configuration.curation_concerns.each do |curation_concern_type|
        expect(rendered).to have_link("New #{curation_concern_type.human_readable_type}", href: new_polymorphic_path([:curation_concern, curation_concern_type]))
      end
    end
  end
  context "for non-admins" do
    it 'does not have links to edit' do
      allow(view).to receive(:can?).and_return(false)
      render partial: 'shared/add_content'
      expect(rendered).not_to have_text("Add")
      expect(rendered).not_to have_text("Admin")
      expect(rendered).not_to have_link("Roles", href: role_management.roles_path)
      Worthwhile.configuration.curation_concerns.each do |curation_concern_type|
        expect(rendered).not_to have_link("New #{curation_concern_type.human_readable_type}", href: new_polymorphic_path([:curation_concern, curation_concern_type]))
      end
    end
  end
end
