require 'spec_helper'
require 'import/object_importer'

describe ObjectImporter do

  let(:source_text)  { FactoryGirl.create(:text) }
  let(:fedora_name) { 'test' }

  let(:properties) { source_text.datastreams['properties'].content }

  before do
    ActiveFedora::Base.delete_all
  end

  after :all do
    ActiveFedora::Base.delete_all
  end

  it 'creates new objects based on the source objects' do
    # In Case Western's fedora, the title is stored in dc:title
    # instead of in descMetadata.  Since the source_object is
    # an object created by absolute, the parser won't find a
    # title in dc:title.  A valid object requires a title, so
    # we need to stub that value.
    DcParser.any_instance.stub(:title) { 'Fake Title' }

    importer = ObjectImporter.new(fedora_name, [source_text.pid])
    old_count = ActiveFedora::Base.count
    importer.import!
    expect(ActiveFedora::Base.count).to eq old_count + 1

    new_object = ActiveFedora::Base.all.select{|obj| obj.pid != source_text.pid }.first
    expect(new_object.datastreams['properties'].content).to eq properties
    expect(new_object.visibility).to eq Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
  end

  it 'keeps track of failed imports' do
    importer = ObjectImporter.new(fedora_name, [source_text.pid])
    importer.import!  # Should fail because there is no title in DC datastream, so new object will be invalid.
    expect(importer.failed_imports).to eq [source_text.pid]
  end

  context 'with files' do
    let (:content) { 'contents of a file' }
    before do
      Worthwhile::GenericFile.delete_all
      source_text.add_file_datastream(content, { dsid: 'weaedm186.pdf', mimeType: 'application/pdf' })
      source_text.save!
      DcParser.any_instance.stub(:title) { 'Fake Title' }
    end

    it 'knows which datastreams should be attached as generic files' do
      importer = ObjectImporter.new(fedora_name, [source_text.pid])
      fedora = importer.connect_to_remote_fedora
      source_object = fedora.find(source_text.pid)
      dsids = importer.dsid_hash(source_object)

      expect(dsids[:attached_files]).to eq ['weaedm186.pdf']
      expect(dsids[:xml].sort).to eq ['properties', 'rightsMetadata']
    end

    it 'attaches the file to the new object' do
      importer = ObjectImporter.new(fedora_name, [source_text.pid])
      importer.import!
      expect(Worthwhile::GenericFile.count).to eq 1
      Worthwhile::GenericFile.all.each do |file|
        file_content = file.datastreams['content'].content
        expect(file_content).to eq content
        expect(file.visibility).to eq Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
      end
    end
  end

end

