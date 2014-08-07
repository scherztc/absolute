require 'spec_helper'
require 'active_fedora/test_support'

describe Audio do
  include ActiveFedora::TestSupport
  subject { Audio.new }

  it_behaves_like 'is_a_curation_concern_model'
  it_behaves_like 'with_access_rights'
  it_behaves_like 'is_embargoable'
  it_behaves_like 'has_dc_metadata'

  describe "#save" do
    it "should register a handle.net handle" do
      expect_any_instance_of(Absolute::Queue::Handle::Create).to receive(:push)
      subject.save(validate: false)
    end

    context "when a pid is provided (as happens in an import)" do
      subject { Audio.new(pid: 'test:123') }
      it "should not register a handle.net handle" do
        expect_any_instance_of(Absolute::Queue::Handle::Create).to_not receive(:push)
        subject.save(validate: false)
      end
    end
  end

end
