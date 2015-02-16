require 'spec_helper'

describe Video, type: :model do
  let(:video) { Video.new(pid: 'ksl:abc123') }

  it 'should have a description' do
    expect(video.human_readable_short_description).to eq "Any Video work, preferably with PBCore xml attached."
  end

  it 'should have a list of acceepted attachments' do
    expect(video.accepted_attachments).to eq ["PBCore","MODS","QDC"]
  end

end
