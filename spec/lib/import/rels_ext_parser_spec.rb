require 'spec_helper'
require 'import/rels_ext_parser'

describe RelsExtParser do
  let(:rels_ext) { fixture_file('files/air_race-RELS.xml').read }
  subject { RelsExtParser.new(rels_ext) }

  it 'parses rdf xml' do
    expect(subject.doc.class).to eq Nokogiri::XML::Document
  end

  describe '#collection_member_ids' do
    it 'returns a list of PIDs for members of a collection' do
      members = subject.collection_member_ids
      expect(members.sort).to eq ['ksl:wrhsairVid-0001',
                                  'ksl:wrhsairVid-0002',
                                  'ksl:wrhsairVid-0003']
    end
  end

end
