require 'spec_helper'

describe BulkUpdateController do
  let(:item1) { FactoryGirl.create(:text, pid: ["ksl:test1"], title: ["Test 1"], type: ["Text"],
      description: ["This is a test item"], subject: ["Rails", "Programming", "yeast"]) }
  let(:item2) { FactoryGirl.create(:image) }

  describe 'an admin user' do
    let(:admin) { FactoryGirl.create(:admin) }
    before { sign_in admin }

    it 'gets the update page' do
      get :index
      expect(response).to be_successful
      expect(response).to render_template(:index)
    end
  end

  describe 'a non-admin user' do 
    let(:user) { FactoryGirl.create(:user) }
    before { sign_in user }

    it 'denies access' do
      get :index
      expect(response).to redirect_to root_url
    end
  end

  # TODO Add integration testing for each function after refacror to DRY up code

end
