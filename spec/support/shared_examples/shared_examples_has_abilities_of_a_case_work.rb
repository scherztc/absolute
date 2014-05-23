require 'spec_helper'
require "cancan/matchers"

shared_examples 'has_abilities_of_a_case_work' do |curation_concern_class|
  subject { Ability.new(current_user) }

  CurationConcern::FactoryHelpers.load_factories_for(self, curation_concern_class)
  let(:a_work) { FactoryGirl.create(private_work_factory_name, user: creating_user ) }
  let(:user) { FactoryGirl.create(:user) }

  it "(this test should use a curation_concern of the correct class)" do
    a_work =  FactoryGirl.create(private_work_factory_name, user: user)
    expect(a_work.class).to eq curation_concern_class
  end

  describe 'without embargo' do
    describe 'creator of object' do
      let(:creating_user) { user }
      let(:current_user) { user }
      it {
        should_not be_able_to(:create, curation_concern_class.new)    # Don't allow regular users to deposit works.
        should be_able_to(:read, a_work)
        should be_able_to(:update, a_work)
        should be_able_to(:destroy, a_work)
      }
    end

    describe 'as a repository manager' do
      let(:manager_user) { FactoryGirl.create(:admin) }
      let(:creating_user) { user }
      let(:current_user) { manager_user }
      it {
        should be_able_to(:create, curation_concern_class.new)
        should be_able_to(:read, a_work)
        should be_able_to(:update, a_work)
        should be_able_to(:destroy, a_work)
      }
    end

    describe 'another authenticated user' do
      let(:creating_user) { FactoryGirl.create(:user) }
      let(:current_user) { user }
      it {
        should_not be_able_to(:create, curation_concern_class.new)
        should_not be_able_to(:read, a_work)
        should_not be_able_to(:update, a_work)
        should_not be_able_to(:destroy, a_work)
      }
    end

    describe 'a nil user' do
      let(:creating_user) { FactoryGirl.create(:user) }
      let(:current_user) { nil }
      it {
        should_not be_able_to(:create, curation_concern_class.new)
        should_not be_able_to(:read, a_work)
        should_not be_able_to(:update, a_work)
        should_not be_able_to(:destroy, a_work)
      }
    end
  end
end
