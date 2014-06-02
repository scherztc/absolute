shared_examples 'is_a_case_curation_concern_controller' do |curation_concern_class, options = {}|
  actions = options.fetch(:actions, :all)

  CurationConcern::FactoryHelpers.load_factories_for(self, curation_concern_class)

  def self.optionally_include_specs(actions, action_name)
    normalized_actions = Array(actions).flatten.compact
    return true if normalized_actions.include?(:all)
    return true if normalized_actions.include?(action_name.to_sym)
    return true if normalized_actions.include?(action_name.to_s)
  end
  its(:curation_concern_type) { should eq curation_concern_class }
  
  it "should return a curation_concern of the correct class" do
    a_work =  FactoryGirl.create(private_work_factory_name, user: user) 
    expect(a_work.class).to eq curation_concern_class 
  end
  

  let(:user) { FactoryGirl.create(:user) }
  let(:admin) {FactoryGirl.create(:admin)}
  before { sign_in user }

  def path_to_curation_concern
    public_send("curation_concern_#{curation_concern_type_underscore}_path", controller.curation_concern.pid)
  end

  if optionally_include_specs(actions, :show)
    describe "#show" do
      context "my own private work" do
        let(:a_work) { FactoryGirl.create(private_work_factory_name, user: user) }
        it "should show me the page" do
          get :show, id: a_work
          expect(response).to be_success
        end
      end
      context "someone elses private work" do
        let(:a_work) { FactoryGirl.create(private_work_factory_name) }
        it "should show 401 Unauthorized" do
          get :show, id: a_work
          expect(response.status).to eq 401
          response.should render_template(:unauthorized)
        end
      end
      context "someone elses public work" do
        let(:a_work) { FactoryGirl.create(public_work_factory_name) }
        it "should show me the page" do
          get :show, id: a_work
          expect(response).to be_success
        end
      end
    end
  end

  if optionally_include_specs(actions, :new)
    describe "#new" do
      let(:user) {FactoryGirl.create(:user)}
      let(:admin) {FactoryGirl.create(:admin)}
      context "when I am a repository manager" do
        before { sign_in admin }
        it "should show me the page" do
          get :new
          expect(response).to be_success
        end
      end
      context "when I am NOT a repository manager" do
        before { sign_in user }
        it "should redirect with 'unauthorized' message" do
          get :new
          expect(flash[:alert]).to include("not authorized")
          expect(response).to redirect_to(root_url)
        end
      end
    end
  end

  if optionally_include_specs(actions, :create)
    describe "#create" do
      context "when I am a repository manager" do
        before { sign_in admin }
        it "should create a work" do
          fake_curation_concern = curation_concern_class.new
          fake_curation_concern.stub(:persisted?).and_return(true)
          fake_curation_concern.stub(:pid).and_return("fake:pid")
          # load_and_authorize_resource calls this and sets controller.curation_concern:
          curation_concern_class.stub(:new).and_return(fake_curation_concern)
          controller.actor = double(:create => true)
          post :create, accept_contributor_agreement: "accept"
          response.should redirect_to path_to_curation_concern
        end
        describe "failure" do
          before { sign_in admin }
          it 'renders the form' do
            controller.actor = double(:create => false)
            post :create, accept_contributor_agreement: "accept"
            expect(response).to render_template('new')
          end
        end
      end
      context "when I am NOT a repository manager" do
        before { sign_in user }
        it "should redirect with 'unauthorized' message" do
          post :create, accept_contributor_agreement: "accept", case_generic_work: {  }
          expect(flash[:alert]).to include("not authorized")
          expect(response).to redirect_to(root_url)
        end
      end
    end


  end

  if optionally_include_specs(actions, :edit)
    describe "#edit" do
      before { sign_in user }
      context "my own private work" do
        let(:a_work) { FactoryGirl.create(private_work_factory_name, user: user) }
        it "should show me the page" do
          get :edit, id: a_work
          expect(response).to be_success
        end
      end
      context "someone elses private work" do
        let(:a_work) { FactoryGirl.create(private_work_factory_name) }
        it "should show 401 Unauthorized" do
          get :edit, id: a_work
          expect(response.status).to eq 401
          response.should render_template(:unauthorized)
        end
      end
      context "someone elses public work" do
        let(:a_work) { FactoryGirl.create(public_work_factory_name) }
        it "should show me the page" do
          get :edit, id: a_work
          expect(response.status).to eq 401
          response.should render_template(:unauthorized)
        end
      end
    end
  end

  if optionally_include_specs(actions, :update)
    describe "#update" do
      let(:a_work) { FactoryGirl.create(default_work_factory_name, user: user) }
      it "should update the work " do
        controller.actor = double(:update => true, :visibility_changed? => false)
        patch :update, id: a_work
        response.should redirect_to path_to_curation_concern
      end
      describe "changing rights" do
        it "should prompt to change the files access" do
          controller.actor = double(:update => true, :visibility_changed? => true)
          patch :update, id: a_work
          response.should redirect_to confirm_curation_concern_permission_path(controller.curation_concern)
        end
      end
      describe "failure" do
        it "renders the form" do
          controller.actor = double(:update => false, :visibility_changed? => false)
          patch :update, id: a_work
          expect(response).to render_template('edit')
        end
      end
    end
  end

end
