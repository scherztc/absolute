require 'spec_helper'
require 'import/dc_parser'

describe DcParser do
  subject { DcParser.from_xml(sample_dc) }
  let(:attrs_hash) { subject.to_attrs_hash }

  it 'returns a hash of attributes and values' do
    expect(attrs_hash[:title]).to eq ["A Qualitative Examination of the Antecedents and Consequences of Accreditation of Nonprofit Organizations"]
    expect(attrs_hash[:description].first).to match /Several nonprofit umbrella associations/
    expect(attrs_hash[:rights].first).to match /including but not limited to commercial or scholarly reproductions, redistribution, publication or transmission/

    expect(attrs_hash[:content_format]).to eq ['application/pdf', '37 p']
    expect(attrs_hash[:creator]).to eq ['Slatten, Lise Anne D.']
    expect(attrs_hash[:date]).to eq ['2007-12']
    expect(attrs_hash[:language]).to eq ['eng']
    expect(attrs_hash[:publisher]).to be_nil
    expect(attrs_hash[:relation]).to eq ['Doctorate of Management Programs']
    expect(attrs_hash[:subject]).to eq ['Accreditation', 'Nonprofit organizations--Management--Evaluation']
    expect(attrs_hash[:type]).to eq ['text']
  end

end


def sample_dc
  <<-END_XML_STRING
<oai_dc:dc xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:oai_dc=\"http://www.openarchives.org/OAI/2.0/oai_dc/\">
  <dc:title>A Qualitative Examination of the Antecedents and Consequences of Accreditation of
            Nonprofit Organizations</dc:title>
  <dc:creator>Slatten, Lise Anne D.</dc:creator>
  <dc:subject>Accreditation</dc:subject>
  <dc:subject>Nonprofit organizations--Management--Evaluation</dc:subject>
  <dc:description>Several nonprofit umbrella associations have implemented assessment and
            certification programs intending to produce institutional improvement for member
            organizations. An analysis of semi-structured interviews guided by institutional theory,
            reveals factors that differentiate among organizations that chose to participate in one
            such program (the Louisiana Standards for Excellence organizational assessment) and
            those that did not. Drawing on organizational learning and accountability literatures,
            the research investigates the antecedents and consequences of accreditation in
            nonprofits. Results indicate that, integrity-enhancement, continuous improvement and
            financial motives drive the decision to seek accreditation, and outcomes of
            remediation-oriented process improvement initiatives were contingent upon staff
            commitment.</dc:description>
  <dc:date>2007-12</dc:date>
  <dc:type>text</dc:type>
  <dc:format>application/pdf</dc:format>
  <dc:format>37 p</dc:format>
  <dc:identifier>ksl:weaedm186</dc:identifier>
  <dc:identifier>http://hdl.handle.net/2186/ksl:weaedm186</dc:identifier>
  <dc:language>eng</dc:language>
  <dc:relation>Doctorate of Management Programs</dc:relation>
  <dc:rights>Kelvin Smith Library, Case Western Reserve University, Cleveland, Ohio, provides
            the information contained in Digital Case, including reproductions of items from its
            collections, for non-commercial, personal, or research use only. All other use,
            including but not limited to commercial or scholarly reproductions, redistribution,
            publication or transmission, whether by electronic means or otherwise, without prior
            written permission is strictly prohibited. For more information contact Digital Case at
            digitalcase@case.edu.</dc:rights>
</oai_dc:dc>
  END_XML_STRING
end
