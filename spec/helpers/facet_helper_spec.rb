require 'spec_helper'

describe FacetHelper do
  describe "#display_collection" do
    let(:collection) { FactoryGirl.create(:collection, title: "Test title") }
    subject { helper.display_collection(collection.id) }
    it { should eq "Test title"}
  end
  
  describe '#display_language' do
    context 'with a real language' do
      subject { helper.display_language('eng') }
      it { should eq 'English'}
    end
    context 'with garbage' do
      subject { helper.display_language('blhearg') }
      it { should eq 'blhearg'}
    end
  end
end
