require 'spec_helper'
require 'support/import_helper'
require 'import/object_importer'

describe ObjectImporter do
  include ImportHelper

  let(:source_text)  { FactoryGirl.create(:text) }
  let(:new_pid) { 'new:123' }
  let(:fedora_name) { 'test' }

  let(:properties) { source_text.datastreams['properties'].content }

  before do
    ActiveFedora::Base.delete_all
    stub_out_set_pid(new_pid)

    # In Case Western's fedora, the title and rights are stored in the DC datastream
    # instead of in descMetadata.  Since the source_object is an object created by absolute,
    # the parser won't find a title or rights in the DC datastream.  A valid object requires
    # a title and rights, so we need to stub those values.
    allow_any_instance_of(DcParser).to receive(:title) { 'Fake Title' }
    allow_any_instance_of(DcParser).to receive(:rights) { Sufia.config.cc_licenses.first }
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
  end

  it 'creates new objects based on the source objects' do
    importer = ObjectImporter.new(fedora_name, [source_text.pid])
    expect {
      importer.import!
    }.to change { ActiveFedora::Base.count }.by(1)

    new_object = ActiveFedora::Base.find(new_pid)
    expect(new_object.datastreams['properties'].content).to eq properties
    expect(new_object.visibility).to eq Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
  end

  it 'keeps track of failed imports' do
    allow_any_instance_of(LegacyObject).to receive(:validate!).and_raise(LegacyObject::ValidationError)
    pid = 'pid:123'
    importer = ObjectImporter.new(fedora_name, [pid])
    importer.import!
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
    end

    it 'characterizes the datastreams' do
      importer = ObjectImporter.new(fedora_name, [source_text.pid])
      fedora = importer.remote_fedora
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

      new_object = Text.find(new_pid)
      expect(new_object.representative).to eq file.pid
    end

    it 'creates linked resources for the external links' do
      importer = ObjectImporter.new(fedora_name, [source_text.pid])
      importer.import!

      urls = Worthwhile::LinkedResource.all.map(&:url).sort
      expect(urls).to eq [link1[:dsLocation], link2[:dsLocation]].sort
      parent_pids = Worthwhile::LinkedResource.all.map(&:batch).map(&:pid).uniq
      expect(parent_pids).to eq [new_pid]
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
  end  # context 'with files and external links'


  describe 'importing a collection' do
    let(:collection) { FactoryGirl.build(:collection) }

    before do
      collection.members << source_text
      collection.save!
    end

    context "when members of the collection have already been imported" do

      it 'sets the members of the collection' do
        importer = ObjectImporter.new(fedora_name, [collection.pid])
        importer.import!

        new_collection = Collection.find(new_pid)
        expect(new_collection.members).to eq [source_text]
        expect(new_collection.member_ids).to eq [source_text.pid]
        expect(source_text.collection_ids.sort).to eq [collection.pid, new_collection.pid].sort
      end
    end

    context "when members of the collection haven't been imported yet" do
      before do
        # Since we are using the same fedora for both source
        # and target, the object that the importer will create
        # already exists, so we'll stub it to pretend that PID
        # doesn't exist yet.
        allow(ActiveFedora::Base).to receive(:exists?).with(source_text.pid).and_return(false)
      end

      it 'imports missing collection members before importing collection' do
        importer = ObjectImporter.new(fedora_name, [collection.pid])
        expect(importer).to receive(:import_object).with(source_text.pid)
        new_collection = FactoryGirl.build(:collection, member_ids: [source_text.pid])
        importer.import_collection(collection, new_collection)
      end
    end
  end

end
