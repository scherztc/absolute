require 'spec_helper'
require 'support/import_helper'
require 'import/object_importer'

describe ObjectImporter do
  include ImportHelper

  let(:source_text)  { ActiveFedora::Base.create!(pid: 'ksl:weaedm186') }
  let(:new_pid) { 'new:123' }
  let(:fedora_name) { 'test' }
  let(:collection) { FactoryGirl.build(:collection) }
  let(:content) { 'contents of a file' }
  let(:xml_content) { 'xml content' }

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
    expect(new_object.date_uploaded).to eq Date.today
    expect(new_object.depositor).to eq 'batchuser@example.com'
    expect(new_object.visibility).to eq Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
    expect(new_object.rights).to eq [Sufia.config.cc_licenses.first]
  end

  it 'keeps track of failed imports' do
    pid = 'pid:123'
    ActiveFedora::Base.find(pid).destroy if ActiveFedora::Base.exists?(pid)
    importer = ObjectImporter.new(fedora_name, [pid])
    importer.import!
    expect(importer.failed_imports).to eq [pid]
  end

  describe '#clean_up_after_failed_import' do
    let(:object)  { FactoryGirl.create(:text) }
    let!(:gf) {
      file = Worthwhile::GenericFile.new(batch_id: object.pid)
      file.save!
      file
    }
    let(:link_attrs) {
      { url: 'http://example.com',
        title: 'A Link',
        batch: object }
    }
    let!(:link1) {
      l1 = Worthwhile::LinkedResource.new(link_attrs)
      l1.save!
      l1
    }

    it 'deletes GenericFile and LinkedResource objects that were created as attachments to the new object' do
      importer = ObjectImporter.new(fedora_name, [object.pid])
      file_count = Worthwhile::GenericFile.count - object.generic_files.count
      link_count = Worthwhile::LinkedResource.count - object.linked_resources.count

      importer.clean_up_after_failed_import(object)
      expect(Worthwhile::GenericFile.count).to eq file_count
      expect(Worthwhile::LinkedResource.count).to eq link_count
    end
  end

  context 'with files and external links' do
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
      allow(source_text.datastreams['DC']).to receive(:content).and_return File.open('spec/fixtures/files/weaedm186-DC.xml').read
      source_text.datastreams['weaedm186.pdf'].dsState = 'D'
      source_text.add_file_datastream(xml_content, { dsid: 'mods.xml', mimeType: 'application/xml' })
      ds1 = source_text.create_datastream(ActiveFedora::Datastream, 'link1', link1)
      ds2 = source_text.create_datastream(ActiveFedora::Datastream, 'link2', link2)
      source_text.add_datastream(ds1)
      source_text.add_datastream(ds2)
      source_text.datastreams['link1'].dsState = 'D'
      source_text.save!
      importer.modified_queue.clear
    end

    let(:importer) { ObjectImporter.new(fedora_name, [source_text.pid]) }

    it 'classifies the datastreams' do
      fedora = importer.remote_fedora
      source_object = fedora.find(source_text.pid)
      dsids = importer.classify_datastreams(source_object)

      expect(dsids[:attached_files]).to eq ['weaedm186.pdf']
      expect(dsids[:xml]).to eq ['mods.xml']
      expect(dsids[:links].sort).to eq ['link1', 'link2']
    end

    it 'attaches the file and xml files to the new object and sets representative' do
      importer.import!

      expect(Worthwhile::GenericFile.count).to eq 1
      file = Worthwhile::GenericFile.first
      expect(file.datastreams['content'].content).to eq content
      expect(file.identifier).to eq ["ksl:weaedm186/weaedm186.pdf"]
      expect(file.visibility).to eq Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC

      new_object = Text.find(new_pid)
      expect(new_object.representative).to eq file.pid
      expect(new_object.datastreams['MODS'].content).to eq xml_content

      expect(importer.modified_queue.size).to eq 5 # one object, one datastream, one xml, two links
    end

    it 'creates linked resources for the external links' do
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
        importer.import!
        expect(importer.failed_imports).to eq [source_text.pid]
      end
    end

    context 'when it has a non-active state' do
      before do
        source_text.state = 'I'
        source_text.save!
      end

      let(:queue) { importer.modified_queue }

      it 'sets the correct state for parent object, attached files, and external links' do
        expect(queue).to receive(:push).with(hash_including(id: 'ksl:weaedm186/weaedm186.pdf'))
        expect(queue).to receive(:push).with(hash_including(id: 'ksl:weaedm186/mods.xml'))
        expect(queue).to receive(:push).with(hash_including(id: 'ksl:weaedm186/link1'))
        expect(queue).to receive(:push).with(hash_including(id: 'ksl:weaedm186/link2'))
        expect(queue).to receive(:push).with(hash_including(id: 'ksl:weaedm186'))
        expect {
          importer.import!
        }.to change { Text.count }.by(1)

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
    let(:created_file) { FactoryGirl.build(:text) }
    before do
      collection.members << created_file
      collection.save!
    end
    context "when members of the collection have already been imported" do

      it 'sets the members of the collection' do
        importer = ObjectImporter.new(fedora_name, [collection.pid])
        importer.import!

        new_collection = Collection.find(new_pid)
        expect(new_collection.members).to eq [created_file]
        expect(new_collection.member_ids).to eq [created_file.pid]
        created_file.collections(true) # this refreshes the cache
        expect(created_file.collection_ids.sort).to eq [collection.pid, new_collection.pid].sort
      end
    end

    context "when members of the collection haven't been imported yet" do
      before do
        # Since we are using the same fedora for both source
        # and target, the object that the importer will create
        # already exists, so we'll stub it to pretend that PID
        # doesn't exist yet.
        allow(ActiveFedora::Base).to receive(:exists?).with(created_file.pid).and_return(false)
      end

      it 'imports missing collection members before importing collection' do
        importer = ObjectImporter.new(fedora_name, [collection.pid])
        expect(importer).to receive(:import_object).with(created_file.pid)
        new_collection = FactoryGirl.build(:collection, member_ids: [created_file.pid])
        importer.import_collection_members(collection, new_collection)
      end
    end

    context 'with file datastreams' do
      before do
        collection.add_file_datastream(content, { dsid: 'thumbnail.jpg', mimeType: 'image/jpeg' })
        collection.save!
      end

      it 'imports the file and sets it as the representative' do
        importer = ObjectImporter.new(fedora_name, [collection.pid])
        expect {
          importer.import!
        }.to change { ActiveFedora::Base.count }.by(2)

        expect(Worthwhile::GenericFile.count).to eq 1
        new_file = Worthwhile::GenericFile.first
        new_collection = Collection.find(new_pid)

        expect(new_collection.representative).to eq new_file.pid
      end
    end
  end

  describe '#select_representative' do
    let!(:gf) {
      file = Worthwhile::GenericFile.new
      file.save!
      file
    }

    context 'when there is only 1 file associated with a work' do
      let(:created_file) { FactoryGirl.build(:text) }
      before do
        created_file.generic_file_ids = [gf.pid]
      end

      it 'that file should be the representative' do
        importer = ObjectImporter.new(fedora_name, [created_file.pid])
        importer.select_representative(created_file)
        expect(created_file.representative).to eq gf.pid
      end
    end

    context 'when the source object is a collection' do
      let!(:gf2) {
        file = Worthwhile::GenericFile.new
        file.save!
        file
      }

      before do
        collection.generic_file_ids = [gf.pid, gf2.pid]
      end

      it 'choose the first file as the representative' do
        importer = ObjectImporter.new(fedora_name, [collection.pid])
        importer.select_representative(collection)
        expect(collection.representative).to eq gf.pid
      end
    end
  end

  describe '#set_rights' do
    context 'when the rights conform to allowed values' do
      let(:rights) { Sufia.config.cc_licenses }

      it 'keeps the source rights' do
        importer = ObjectImporter.new(fedora_name, ['pid:1'])
        expect(importer.set_rights(rights, 'pid:1')).to eq rights
      end
    end

    context 'when the rights do not conform to allowed values' do
      let(:rights) { 'Some other rights statement' }

      it 'keeps the source rights' do
        importer = ObjectImporter.new(fedora_name, ['pid:1'])
        expect(importer.set_rights(rights, 'pid:1')).to eq rights
      end
    end

    context 'when there is no rights statement' do
      let(:rights) { nil }

      it 'selects one of the acceptable rights statements' do
        importer = ObjectImporter.new(fedora_name, ['pid:1'])
        expect(importer.set_rights(rights, 'pid:1')).to eq Sufia.config.cc_licenses.first
      end
    end
  end

end
