require 'spec_helper'

describe FacetHelper do
  describe "#display_collection" do
    let(:collection) { FactoryGirl.create(:collection, title: "Test title") }
    subject { helper.display_collection(collection.id) }
    it { should eq "Test title"}
  end
  
  describe "#display_language" do
    subject { helper.display_language('eng') }
    it { should eq "English"}
  end
end
