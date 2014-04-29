# Generated via
#  `rails generate curate:work Text`
require 'spec_helper'

describe CurationConcern::TextsController do
  it_behaves_like 'is_a_curation_concern_controller', Text, actions: [:create, :update, :show]
  
  it "has Curate CurationConcern::Controller#edit behaviors" do
    pending "Must implement CanCan error handling to return 401, then the default tests from Curate will work"
    it_behaves_like 'is_a_curation_concern_controller', Text, actions: [:edit]
  end
  
  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  def path_to_curation_concern
    public_send("curation_concern_#{curation_concern_type_underscore}_path", controller.curation_concern)
  end

  render_views
  
  # The default test for #new in Curate basically just tests that DOI support is turned on.  We turned off DOI support.   
  # This is the override.
  describe "#new" do
    context "my work" do
      it "should show me the page" do
        get :new
        expect(response).to be_success
        expect(response.body).to have_tag('h2', :text => 'Describe Your Text')
      end
    end
  end
  
end
