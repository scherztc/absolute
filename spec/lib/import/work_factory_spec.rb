require 'spec_helper'
require 'support/import_helper'
require 'import/work_factory'

describe WorkFactory do
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
    subject { WorkFactory.new(object) }

    it 'raises an error' do
      expect(ActiveFedora::Base).to receive(:exists?).and_return(true) 
      expect { subject.build_work }.to raise_error(PidAlreadyInUseError)
    end
  end


  describe '#build_work' do
    before { stub_out_set_pid 'testme:1' }
    let(:object) { ActiveFedora::Base.create }
    subject { WorkFactory.new(object).build_work }

    describe 'copying values' do
      let (:rights_statement) { Sufia.config.cc_licenses.first }
      let (:content) {
        "<oai_dc:dc xmlns:oai_dc=\"http://www.openarchives.org/OAI/2.0/oai_dc/\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\">
           <dc:language>en</dc:language>
           <dc:rights>#{rights_statement}</dc:rights>
         </oai_dc:dc>"
      }
      before do
        object.datastreams['DC'].content = content
      end

      it "should recode language to ISO 639-3" do
        expect(subject.language).to eq ['eng']
      end

      context "with an allowed rights value" do
        its (:rights) { should eq [rights_statement] }
      end

      context "with an unknown rights value" do
        let (:rights_statement) { 'WHat?' }
        it "should raise an error" do
          expect { subject }.to raise_error LegacyObject::ValidationError, 'Rights assertion for testme:1: "["WHat?"]" was not in the allowed list.'
        end
      end
    end
  end

  describe '#work_class' do
    let(:object) { ActiveFedora::Base.create }
    subject { WorkFactory.new(object).work_class }
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
