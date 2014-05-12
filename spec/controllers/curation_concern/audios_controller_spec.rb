# Generated via
#  `rails generate curate:work Text`
require 'spec_helper'

describe CurationConcern::AudiosController do
  it_behaves_like 'is_a_curation_concern_controller', Audio, actions: [:create, :update, :show]
  
  it "has Curate CurationConcern::Controller#edit behaviors" do
    pending "Must implement CanCan error handling to return 401, then the default tests from Curate will work"
    it_behaves_like 'is_a_curation_concern_controller', Audio, actions: [:edit]
  end
  
  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  render_views
  
  # The default test for #new in Curate basically just tests that DOI support is turned on.  We turned off DOI support.   
  # This is the override.
  describe "#new" do
    context "my work" do
      it "should show me the page" do
        get :new
        expect(response).to be_success
        expect(response.body).to have_tag('h2', :text => 'Describe Your Audio')
      end
    end
  end
  
end