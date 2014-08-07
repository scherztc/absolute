require 'spec_helper'
require 'export/handles'

describe Export::Handles do
  let(:file_name) { 'tmp/test_file.txt' }
  subject { Export::Handles.new(namespace) }

  before do
    queue = Absolute::Queue::Handle::Modify.new(Resque.redis, JSON)
    queue.clear
    queue.push id: "ksl:weaedm186/mods.xml", url: "http://library.case.edu/digitalcase/downloads/new:123?datastream_id=MODS", verb: "MODIFY"
    queue.push id: "ksl:weaedm186/weaedm186.pdf", url: "http://library.case.edu/digitalcase/concern/generic_files/ksl:t435jw95s", verb: "MODIFY"
    queue.push id: "ksl:weaedm186/link1", url: "http://library.case.edu/digitalcase/concern/linked_resources/ksl:t435jw962", verb: "MODIFY"
    queue.push id: "ksl:weaedm186", url: "http://library.case.edu/digitalcase/concern/texts/new:123", verb: "MODIFY"

    File.unlink(file_name) if File.exists? file_name
    allow(subject).to receive(:puts) #squelch stdout
  end

  let(:namespace) { '2279' }
  let(:file_contents) { File.open(file_name).read }

  it "should create a file" do
    expect(subject).to receive(:file_name).and_return(file_name).at_least(:once)
    subject.export!
    expect(file_contents).to eq "MODIFY 2279/ksl:weaedm186/mods.xml\n" +
       "2 URL 86400 1110 UTF8 http://library.case.edu/digitalcase/downloads/new:123?datastream_id=MODS\n\n" +
       "MODIFY 2279/ksl:weaedm186/weaedm186.pdf\n" +
       "2 URL 86400 1110 UTF8 http://library.case.edu/digitalcase/concern/generic_files/ksl:t435jw95s\n\n" +
       "MODIFY 2279/ksl:weaedm186/link1\n" +
       "2 URL 86400 1110 UTF8 http://library.case.edu/digitalcase/concern/linked_resources/ksl:t435jw962\n\n" +
       "MODIFY 2279/ksl:weaedm186\n" +
       "2 URL 86400 1110 UTF8 http://library.case.edu/digitalcase/concern/texts/new:123\n\n"
  end
end
