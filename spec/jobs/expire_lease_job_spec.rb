require 'spec_helper'

describe ExpireLeaseJob do

  let(:past_date) { Date.today - 2 }

  # We can't just use apply_lease because the date is in the past.
  let(:lease1) { build(:text, lease_expiration_date: past_date.to_s,
                        visibility: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC,
                        visibility_during_lease: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC,
                        visibility_after_lease: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE) }

  context "works" do
    let(:a_file) { build(:generic_file, visibility: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC) }


    before do
      lease1.generic_files << a_file
      lease1.save(validate: false)
    end

    it "should update all the expired leases" do
      expect(Hydra::LeaseService).to receive(:assets_with_expired_leases).and_return [lease1]
      expect {
        ExpireLeaseJob.perform
      }.to change { lease1.visibility }.from('open').to('restricted').and change {
        a_file.reload.visibility }.from('open').to('restricted')

    end
  end

  context "generic files" do
    # We can't just use apply_lease because the date is in the past.
    let(:a_file) { build(:generic_file, lease_expiration_date: "2014-09-23",
                        visibility_during_lease: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC,
                        visibility_after_lease: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE,
                        visibility: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC) }

    before do
      a_file.save(validate: false)
    end

    it "should update all the expired files" do
      expect(Hydra::LeaseService).to receive(:assets_with_expired_leases).and_return [a_file]
      expect {
        ExpireLeaseJob.perform
      }.to change { a_file.reload.visibility }.from('open').to('restricted')

    end
  end
end
