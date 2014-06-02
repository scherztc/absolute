require 'spec_helper'

describe Collection do
  let(:subject) { FactoryGirl.create(:collection) }
  let(:reloaded_subject) { Collection.find(subject.pid) }

  it 'can be part of a collection' do
    expect(subject.can_be_member_of_collection?(double)).to be true
  end

  it 'can contain another collection' do
    another_collection = FactoryGirl.create(:collection)
    subject.members << another_collection
    expect(subject.members).to eq [another_collection]
  end

  it 'updates solr with pids of its parent collections' do
    another_collection = FactoryGirl.create(:collection)
    another_collection.members << subject
    another_collection.save
    expect(subject.reload.to_solr[Solrizer.solr_name(:collection)]).to eq [another_collection.pid]
  end

  it 'cannot contain itself' do
    subject.members << subject
    subject.save
    expect(subject.reload.members).to eq []
  end

  describe "when visibility is private" do
    it "should not be open_access?" do
      expect(subject).to_not be_open_access
    end
    it "should not be authenticated_only_access?" do
      expect(subject).to_not be_authenticated_only_access
    end
    it "should not be private_access?" do
      expect(subject).to be_private_access
    end
  end

  describe "visibility" do
    it "should have visibility accessor" do
      expect(subject.visibility).to eq Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
    end
    it "should have visibility writer" do
      subject.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
      expect(subject).to be_open_access
    end
  end

  describe "to_solr on a saved object" do
    let(:solr_doc) {subject.to_solr}
    it "should have a generic_type_sim" do
      expect(solr_doc['generic_type_sim']).to eq ['Collection']
    end

  end

  describe '#human_readable_type' do
    it "indicates collection" do
      expect(subject.human_readable_type).to eq 'Collection'
    end
  end
end
