require 'spec_helper'

describe Audio do
  let(:audio) { Audio.new(pid: 'ksl:abc123') }

  it 'should have a human readable description' do
    expect(audio.human_readable_short_description).to eq "Any Audio work, possibly with PBCore xml attached."
  end

  it 'should have a list of metadata files that it will accept' do
    expect(audio.accepted_attachments).to eq ["PBCore", "MODS", "QDC"]
  end

end
