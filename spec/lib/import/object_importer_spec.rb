require 'spec_helper'
require 'support/import_helper'
require 'import/object_importer'

describe ObjectImporter do
  include ImportHelper

  let(:source_text)  { FactoryGirl.create(:text) }
  let(:fedora_name) { 'test' }

  let(:properties) { source_text.datastreams['properties'].content }

  before do
    ActiveFedora::Base.delete_all
    stub_out_set_pid
  end

  after :all do
    ActiveFedora::Base.delete_all
  end

  it 'has a log file' do
    now = Time.now
    allow(Time).to receive(:now) { now }

    timestamp = now.strftime("%Y_%m_%d_%H%M%S")
    dir = File.join(Rails.root, 'log', 'imports')
    file = File.join(dir, "object_import_#{timestamp}.log")

    importer = ObjectImporter.new(fedora_name, ['pid:1'])
    expect(importer.log_file).to eq file

    importer.import!
    expect(File.exist?(file)).to eq true
  end

  it 'creates new objects based on the source objects' do
    # In Case Western's fedora, the title is stored in dc:title
    # instead of in descMetadata.  Since the source_object is
    # an object created by absolute, the parser won't find a
    # title in dc:title.  A valid object requires a title, so
    # we need to stub that value.
    allow_any_instance_of(DcParser).to receive(:title) { 'Fake Title' }

    importer = ObjectImporter.new(fedora_name, [source_text.pid])
    old_count = ActiveFedora::Base.count
    importer.import!
    expect(ActiveFedora::Base.count).to eq old_count + 1

    new_object = ActiveFedora::Base.all.select{|obj| obj.pid != source_text.pid }.first
    expect(new_object.datastreams['properties'].content).to eq properties
    expect(new_object.visibility).to eq Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
  end

  it 'keeps track of failed imports' do
    pid = 'pid:123'
    importer = ObjectImporter.new(fedora_name, [pid])
    importer.import!  # Should fail because there is no title in DC datastream, so new object will be invalid.
    expect(importer.failed_imports).to eq [pid]
  end


  context 'with files and external links' do
    let(:content) { 'contents of a file' }

    # Try to simulate what external link datastreams look like
    # in Digital Case 1.0
    let(:link1) {{ controlGroup: 'R',
                   dsLocation: 'http://example.com/1',
                   label: 'Link to Part 1',
                   mimeType: 'text/xml' }}
    let(:link2) {{ controlGroup: 'E',
                   dsLocation: 'http://example.com/2',
                   label: 'Link to Part 2',
                   mimeType: 'text/xml' }}

    before do
      User.first_or_create(username: User.batchuser_key)
      source_text.add_file_datastream(content, { dsid: 'weaedm186.pdf', mimeType: 'application/pdf' })
      source_text.datastreams['weaedm186.pdf'].dsState = 'D'
      ds1 = source_text.create_datastream(ActiveFedora::Datastream, 'link1', link1)
      ds2 = source_text.create_datastream(ActiveFedora::Datastream, 'link2', link2)
      source_text.add_datastream(ds1)
      source_text.add_datastream(ds2)
      source_text.datastreams['link1'].dsState = 'D'
      source_text.save!
      allow_any_instance_of(DcParser).to receive(:title) { 'Fake Title' }
    end

    it 'characterizes the datastreams' do
      importer = ObjectImporter.new(fedora_name, [source_text.pid])
      fedora = importer.connect_to_remote_fedora
      source_object = fedora.find(source_text.pid)
      dsids = importer.characterize_datastreams(source_object)

      expect(dsids[:attached_files]).to eq ['weaedm186.pdf']
      expect(dsids[:xml].sort).to eq ['properties', 'rightsMetadata']
      expect(dsids[:links].sort).to eq ['link1', 'link2']
    end

    it 'attaches the file to the new object and sets representative' do
      importer = ObjectImporter.new(fedora_name, [source_text.pid])
      importer.import!

      expect(Worthwhile::GenericFile.count).to eq 1
      file = Worthwhile::GenericFile.first
      file_content = file.datastreams['content'].content
      expect(file_content).to eq content
      expect(file.visibility).to eq Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC

      expect(Text.count).to eq 2
      new_pid = (Text.all.map(&:pid) - [source_text.pid]).first
      new_object = Text.find(new_pid)
      expect(new_object.representative).to eq file.pid
    end

    it 'creates linked resources for the external links' do
      importer = ObjectImporter.new(fedora_name, [source_text.pid])
      importer.import!

      urls = Worthwhile::LinkedResource.all.map(&:url).sort
      expect(urls).to eq [link1[:dsLocation], link2[:dsLocation]].sort
      new_text_pid = (Text.all.map(&:pid) - [source_text.pid]).first
      parent_pids = Worthwhile::LinkedResource.all.map(&:batch).map(&:pid).uniq
      expect(parent_pids).to eq [new_text_pid]
    end

    context 'when it fails to create the linked resource' do
      before do
        attrs = { url: link1[:dsLocation], title: link1[:label] }
        failed_link = Worthwhile::LinkedResource.new(attrs)
        failed_actor = CurationConcern::LinkedResourceActor.new(failed_link, User.batchuser, link1)
        allow(failed_actor).to receive(:create) { false }
        allow(Worthwhile::CurationConcern).to receive(:actor) { failed_actor }
      end

      it 'logs the pid as a failed import' do
        importer = ObjectImporter.new(fedora_name, [source_text.pid])
        importer.import!
        expect(importer.failed_imports).to eq [source_text.pid]
      end
    end

    context 'when it has a non-active state' do
      before do
        source_text.state = 'I'
        source_text.save!
      end

      it 'sets the correct state for parent object, attached files, and external links' do
        importer = ObjectImporter.new(fedora_name, [source_text.pid])
        importer.import!

        expect(Text.count).to eq 2
        new_pid = (Text.all.map(&:pid) - [source_text.pid]).first
        new_object = Text.find(new_pid)
        expect(new_object.state).to eq 'I'

        expect(Worthwhile::GenericFile.count).to eq 1
        file = Worthwhile::GenericFile.first
        expect(file.state).to eq 'D'
        expect(file.datastreams['content'].state).to eq 'D'

        link_states = Worthwhile::LinkedResource.all.map(&:state).sort
        expect(link_states).to eq ['A', 'D']
        link_content_states = Worthwhile::LinkedResource.all.map {|link| link.datastreams['content'].state }.sort
        expect(link_content_states).to eq ['A', 'D']
      end
    end
  end

end

