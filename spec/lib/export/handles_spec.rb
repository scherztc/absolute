require 'spec_helper'
require 'export/handles'

describe Export::Handles do
  let(:file_name) { 'tmp/test_file.txt' }
  before do
    ActiveFedora::Base.destroy_all
    File.unlink(file_name) if File.exists? file_name
  end

  let!(:text) { FactoryGirl.create(:text) }
  let!(:generic_work) { FactoryGirl.create(:case_generic_work) }
  let!(:collection) { FactoryGirl.create(:collection) }

  subject { Export::Handles.new('2279', 'library.case.edu') } # 2279 is testing namespace
  
  let(:file_contents) { File.open(file_name).read }

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
