require 'spec_helper'
require 'import/dsid_map'

describe DsidMap do

  it 'maps the source dsid names to the target/local dsid names' do
    expect(DsidMap.target_dsid('unknown dsid')).to eq 'unknown dsid'
    expect(DsidMap.target_dsid('MODS')).to eq 'MODS'
    expect(DsidMap.target_dsid('MODS.xml')).to eq 'MODS'
    expect(DsidMap.target_dsid('mods.xml')).to eq 'MODS'
    expect(DsidMap.target_dsid('PBCORE.xml')).to eq 'PBCore'
  end

end
