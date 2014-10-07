require 'spec_helper'

describe CurationConcern::CaseGenericWorkActor do

  describe "attachments" do
    let(:curation_concern) { CaseGenericWork.new(pid: Worthwhile::CurationConcern.mint_a_pid )}
    let(:visibility) { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED }
    let(:user) { FactoryGirl.create(:user) }
    let(:tei) { fixture_file_upload('files/anoabo00-TEI.xml', 'application/xml') }
    let(:teip5) { fixture_file_upload('files/anoabo00-TEIP5.xml', 'application/xml') }
    let(:mods) { fixture_file_upload('files/anoabo00-MODS.xml', 'application/xml') }

    subject {
      Worthwhile::CurationConcern.actor(curation_concern, user, attributes)
    }
    let(:attributes) {
      FactoryGirl.attributes_for(:case_generic_work, visibility: visibility).tap {|a|
        a[:TEI] = tei
        a[:TEIP5] = teip5
        a[:MODS] = mods
      }
    }

    it 'should save accepted attachment types to corresponding datastreams' do
      expect(subject.create).to be true
      expect(curation_concern).to be_persisted
      expect(curation_concern.datastreams["TEI"].read).to eq fixture_file('files/anoabo00-TEI.xml').read
      expect(curation_concern.datastreams["TEIP5"].read).to eq fixture_file('files/anoabo00-TEIP5.xml').read
      expect(curation_concern.datastreams["MODS"].read).to eq fixture_file('files/anoabo00-MODS.xml').read
    end
  end

  describe "handles" do
    let(:curation_concern) { CaseGenericWork.new }
    let(:visibility) { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED }
    let(:user) { FactoryGirl.create(:user) }
    subject {
      Worthwhile::CurationConcern.actor(curation_concern, user, attributes)
    }

    let(:attributes) { FactoryGirl.attributes_for(:case_generic_work, visibility: visibility) }

    it 'should add to the handle.net queue' do
      expect_any_instance_of(Absolute::Queue::Handle::Create).to receive(:push)
      subject.create
      expect(curation_concern).to be_persisted
    end
  end

end
