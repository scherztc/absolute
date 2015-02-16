require 'spec_helper'

describe CaseGenericWork, type: :model do
  let(:generic_work) { CaseGenericWork.new(pid: 'ksl:abc123') }

  it 'should have a type of Other' do
    expect(generic_work.human_readable_type).to eq "Other"
  end

  it 'should have a description' do
    expect(generic_work.human_readable_short_description).to eq "Any type of work, with files associated and XML optionally attached."
  end

  it 'should have a list of valid attachments' do
    expect(generic_work.accepted_attachments).to eq ["MODS", "TEI", "TEIP5", "VRA", "PBCore", "METS", "QDC"]
  end

end
