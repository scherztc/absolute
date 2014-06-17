require 'spec_helper'
require 'support/import_helper'
require 'import/object_factory'

describe ObjectFactory do
  include ImportHelper

  let(:mpg) {{ dsid: 'HELLO.MPG', mimeType: 'video/mpeg' }}
  let(:wav) {{ dsid: 'HELLO.WAV', mimeType: 'audio/x-wav' }}
  let(:mp3) {{ dsid: 'HELLO.MP3', mimeType: 'audio/mpeg' }}
  let(:pdf) {{ dsid: 'HELLO.PDF', mimeType: 'application/pdf' }}
  let(:tei) {{ dsid: 'TEI.XML',   mimeType: 'text/xml' }}
  let(:gif) {{ dsid: 'HELLO.GIF', mimeType: 'image/gif' }}

  # Datastreams that are External or Redirect control group:
  let(:video)   {{ dsid: 'VIDEO', mimeType: 'text/xml', controlGroup: 'R' }}
  let(:article) {{ dsid: 'ARTICLE', mimeType: 'text/xml', controlGroup: 'E' }}


  describe 'importing an object with a PID that already exists' do
    let!(:object) { ActiveFedora::Base.create }
    subject { ObjectFactory.new(object) }

    it 'raises an error' do
      expect(ActiveFedora::Base).to receive(:exists?).and_return(true) 
      expect { subject.build_object }.to raise_error(PidAlreadyInUseError)
    end
  end

  describe 'validate_datastreams!' do
    let(:object) { ActiveFedora::Base.new(pid: 'test:123') }
    subject { ObjectFactory.new(object) }

    before do
      allow(object).to receive(:datastreams).and_return({ 'mods.xml' => double, 'MODS' => double } )
    end

    it 'should raise errors if there are duplicates' do
      expect {
        subject.validate_datastreams!
      }.to raise_error 'Datastreams are not unique for test:123'

    end
  end

  describe '#build_object' do
    before { stub_out_set_pid 'testme:1' }
    let(:object) { ActiveFedora::Base.create }
    subject { ObjectFactory.new(object).build_object }

    let(:attributes) { subject.last }

    let (:rights_statement) { Sufia.config.cc_licenses.first }
    let (:content) {
      "<oai_dc:dc xmlns:oai_dc=\"http://www.openarchives.org/OAI/2.0/oai_dc/\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\">
         <dc:language>en</dc:language>
         <dc:rights>#{rights_statement}</dc:rights>
       </oai_dc:dc>"
    }

    let (:rels_content) {
      "<rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:rel=\"info:fedora/fedora-system:def/relations-external#\">
        <rdf:Description rdf:about=\"info:fedora/#{object.pid}\">
          <rel:hasCollectionMember rdf:resource=\"info:fedora/testme:2\"></rel:hasCollectionMember>
        </rdf:Description>
      </rdf:RDF>"
    }

    describe 'copying values' do
      before do
        object.datastreams['DC'].content = content
      end

      it "should recode language to ISO 639-3" do
        expect(attributes[:language]).to eq ['eng']
      end

      context "with an allowed rights value" do
        it 'should have a rights attribute' do
          expect(attributes[:rights]).to eq [rights_statement]
        end
      end

      context "with an unknown rights value" do
        let (:rights_statement) { 'WHat?' }
        it "should raise an error" do
          expect { subject }.to raise_error LegacyObject::ValidationError, 'Rights assertion for testme:1: "["WHat?"]" was not in the allowed list.'
        end
      end
    end
  end

  describe '#object_class' do
    let(:object) { ActiveFedora::Base.create }
    subject { ObjectFactory.new(object).object_class }

    context 'the source object has collection members' do
      let(:object) { FactoryGirl.create(:collection) }
      let(:member) { FactoryGirl.create(:text) }

      before do
        object.members << member
        object.save!
      end

      it { should eq Collection }
    end

    context 'the source object contains an MPG datastream' do
      before {
        object.add_file_datastream('pdf content', pdf)
        object.add_file_datastream('mpg content', mpg)
      }

      it { should eq Video }
    end

    context 'the source object contains a WAV datastream' do
      before {
        object.add_file_datastream('wav content', wav)
      }

      it { should eq Audio }
    end

    context 'the source object contains a MP3 datastream' do
      before {
        object.add_file_datastream('mp3 content', mp3)
      }

      it { should eq Audio }
    end

    context 'the source object contains both audio and video datastreams' do
      before {
        object.add_file_datastream('pdf content', pdf)
        object.add_file_datastream('mpg content', mpg)
        object.add_file_datastream('mp3 content', mp3)
      }

      it { should eq Video }
    end

    context 'the source object contains TEI datastreams' do
      before {
        object.add_file_datastream('pdf content', pdf)
        object.add_file_datastream('tei content', tei)
      }

      it { should eq Text }
    end

    context 'the source object contains both TEI and MP3 datastreams' do
      before {
        object.add_file_datastream('pdf content', pdf)
        object.add_file_datastream('tei content', tei)
        object.add_file_datastream('mp3 content', mp3)
      }

      it { should eq Audio }
    end

    context 'the source object contains GIF datastream' do
      before {
        object.add_file_datastream('pdf content', pdf)
        object.add_file_datastream('gif content', gif)
      }

      it { should eq Image }
    end

    context 'the source object contains both image and TEI' do
      before {
        object.add_file_datastream('gif content', gif)
        object.add_file_datastream('tei content', tei)
      }

      it { should eq Text }
    end

    context 'the source object contains a PDF datastream' do
      before {
        object.add_file_datastream('pdf content', pdf)
      }

      it { should eq Text }
    end

    context 'the source object has a link called "VIDEO"' do
      before {
        ds = object.create_datastream(ActiveFedora::Datastream, 'VIDEO', video)
        object.add_datastream(ds)
      }

      it { should eq Video }
    end

    context 'the source object has a link called "ARTICLE"' do
      before {
        ds = object.create_datastream(ActiveFedora::Datastream, 'ARTICLE', article)
        object.add_datastream(ds)
      }

      it { should eq Text }
    end

    context "when it can't determine the type of object" do
      it { should eq Text }
    end
  end
end
