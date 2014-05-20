require 'spec_helper'

describe AdminMenuController do

  describe 'an admin user' do
    let(:admin) { FactoryGirl.create(:admin) }
    before { sign_in admin }

    it 'gets show page' do
      get :show
      expect(response).to be_successful
      expect(response).to render_template(:show)
    end
  end

  describe 'a non-admin user' do
    let(:user) { FactoryGirl.create(:user) }
    before { sign_in user }

    it 'denies access' do
      get :show
      expect(response).to redirect_to root_url
    end
  end

end
