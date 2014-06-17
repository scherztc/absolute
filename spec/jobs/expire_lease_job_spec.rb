require 'spec_helper'

describe ExpireLeaseJob do

  let(:past_date) { Date.today - 2 }
  let(:lease1) { FactoryGirl.build(:text, lease_expiration_date: past_date.to_s,
                        visibility: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC,
                        visibility_during_lease: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC,
                        visibility_after_lease: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE) }
  before do
    lease1.save(validate: false)
  end

  it "should update all the expired leases" do
    expect(Hydra::LeaseService).to receive(:assets_with_expired_leases).and_return [lease1]
    expect {
      ExpireLeaseJob.perform
    }.to change { lease1.visibility }.from('open').to('restricted')

  end
end
