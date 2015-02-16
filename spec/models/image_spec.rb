require 'spec_helper'

describe Image, type: :model do

  let(:image) do
    image = Image.new(pid: 'ksl:abc123')
    image.title = ["A Test Image"]
    return image
  end

  it 'has a list of valid metadata attachments' do
    expect(image.accepted_attachments).to eq ["VRA", "MODS", "QDC"]
  end

  it 'has a human readable description' do
    expect(image.human_readable_short_description).to eq "Any Image work, preferably with VRA xml attached."
  end

  it 'should export as endnote' do
    expect(image.export_as_endnote).to eq "%0 Image\n%T A Test Image\n%~ Digital Case\n%W Case Western Reserve University"
  end

  describe '#to_param' do
    it 'returns the images pid' do
      expect(image.to_param).to eq 'ksl:abc123'
    end
  end
end
