require 'spec_helper'
require 'export/handles'

describe Export::Handles do
  let(:file_name) { 'tmp/test_file.txt' }
  before do
    ActiveFedora::Base.destroy_all
    File.unlink(file_name) if File.exists? file_name
    allow(subject).to receive(:puts) #squelch stdout
  end

  let!(:text) { FactoryGirl.create(:text) }
  let!(:generic_work) { FactoryGirl.create(:case_generic_work) }
  let!(:collection) { FactoryGirl.create(:collection) }

  let(:namespace) { '2279' }
  let(:hostname) { 'library.case.edu' }
  let(:file_contents) { File.open(file_name).read }

  context "without pids" do
    subject { Export::Handles.new('MODIFY', namespace, hostname) }
    
    it "should create a file" do
      expect(subject).to receive(:file_name).and_return(file_name).at_least(:once)
      subject.export!
      expect(file_contents).to eq "MODIFY 2279/#{text.id}\n" +
         "2 URL 86400 1110 UTF8 http://library.case.edu/digitalcase/concern/texts/#{text.id}\n\n" +
         "MODIFY 2279/#{generic_work.id}\n" +
         "2 URL 86400 1110 UTF8 http://library.case.edu/digitalcase/concern/case_generic_works/#{generic_work.id}\n\n" +
         "MODIFY 2279/#{collection.id}\n" +
         "2 URL 86400 1110 UTF8 http://library.case.edu/digitalcase/collections/#{collection.id}\n\n"
    end
  end

  context "with pids" do
    subject { Export::Handles.new('CREATE', namespace, hostname, [collection.id]) }
    
    it "should create a file" do
      expect(subject).to receive(:file_name).and_return(file_name).at_least(:once)
      subject.export!
      expect(file_contents).to eq "CREATE 2279/#{collection.id}\n" +
         "2 URL 86400 1110 UTF8 http://library.case.edu/digitalcase/collections/#{collection.id}\n\n"
    end
  end
end
