require 'spec_helper'

describe Collection do
  let(:subject) { FactoryGirl.create(:collection) }
  let(:reloaded_subject) { Collection.find(subject.pid) }

  it 'can be part of a collection' do
    expect(subject.can_be_member_of_collection?(double)).to be_true
  end

  it 'can contain another collection' do
    another_collection = FactoryGirl.create(:collection)
    subject.members << another_collection
    subject.members.should == [another_collection]
  end

  it 'updates solr with pids of its parent collections' do
    another_collection = FactoryGirl.create(:collection)
    another_collection.members << subject
    another_collection.save
    subject.reload.to_solr[Solrizer.solr_name(:collection)].should == [another_collection.pid]
  end

  it 'cannot contain itself' do
    subject.members << subject
    subject.save
    subject.reload.members.should == []
  end

  describe "when visibility is private" do
    it "should not be open_access?" do
      subject.should_not be_open_access
    end
    it "should not be authenticated_only_access?" do
      subject.should_not be_authenticated_only_access
    end
    it "should not be private_access?" do
      subject.should be_private_access
    end
  end

  describe "visibility" do
    it "should have visibility accessor" do
      subject.visibility.should == Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
    end
    it "should have visibility writer" do
      subject.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
      subject.should be_open_access
    end
  end

  describe "to_solr on a saved object" do
    let(:solr_doc) {subject.to_solr}
    it "should have a generic_type_sim" do
      solr_doc['generic_type_sim'].should == ['Collection']
    end

  end

  describe '#human_readable_type' do
    it "indicates collection" do
      subject.human_readable_type.should == 'Collection'
    end
  end
end
