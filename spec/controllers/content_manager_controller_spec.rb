require 'spec_helper'

describe ContentManagerController do

  describe '#index' do
    describe 'an admin user' do
      let(:admin) { FactoryGirl.create(:admin) }
      before { sign_in admin }

      it 'gets the index page' do
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
  end

end
