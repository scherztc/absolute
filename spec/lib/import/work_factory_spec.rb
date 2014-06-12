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


  describe 'build_work:' do
    before { stub_out_set_pid }
    let(:object) { ActiveFedora::Base.create }
    subject { WorkFactory.new(object).build_work }

    describe 'transforming' do
      before do
        object.datastreams['DC'].content = '<oai_dc:dc xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:dc="http://purl.org/dc/elements/1.1/">
  <dc:language>en</dc:language>
</oai_dc:dc>'
      end
      its (:language) { should eq ['eng'] }
    end

    context 'the source object contains an MPG datastream' do
      before {
        object.add_file_datastream('pdf content', pdf)
        object.add_file_datastream('mpg content', mpg)
      }

      it { should be_new_record }
      it { should be_kind_of Video }
    end

    context 'the source object contains a WAV datastream' do
      before {
        object.add_file_datastream('wav content', wav)
      }

      it { should be_kind_of Audio }
    end

    context 'the source object contains a MP3 datastream' do
      before {
        object.add_file_datastream('mp3 content', mp3)
      }

      it { should be_kind_of Audio }
    end

    context 'the source object contains both audio and video datastreams' do
      before {
        object.add_file_datastream('pdf content', pdf)
        object.add_file_datastream('mpg content', mpg)
        object.add_file_datastream('mp3 content', mp3)
      }

      it { should be_kind_of Video }
    end

    context 'the source object contains TEI datastreams' do
      before {
        object.add_file_datastream('pdf content', pdf)
        object.add_file_datastream('tei content', tei)
      }

      it { should be_kind_of Text }
    end

    context 'the source object contains both TEI and MP3 datastreams' do
      before {
        object.add_file_datastream('pdf content', pdf)
        object.add_file_datastream('tei content', tei)
        object.add_file_datastream('mp3 content', mp3)
      }

      it { should be_kind_of Audio }
    end

    context 'the source object contains GIF datastream' do
      before {
        object.add_file_datastream('pdf content', pdf)
        object.add_file_datastream('gif content', gif)
      }

      it { should be_kind_of Image }
    end

    context 'the source object contains both image and TEI' do
      before {
        object.add_file_datastream('gif content', gif)
        object.add_file_datastream('tei content', tei)
      }

      it { should be_kind_of Text }
    end

    context 'the source object contains a PDF datastream' do
      before {
        object.add_file_datastream('pdf content', pdf)
      }

      it { should be_kind_of Text }
    end

    context 'the source object has a link called "VIDEO"' do
      before {
        ds = object.create_datastream(ActiveFedora::Datastream, 'VIDEO', video)
        object.add_datastream(ds)
      }

      it { should be_kind_of Video }
    end

    context 'the source object has a link called "ARTICLE"' do
      before {
        ds = object.create_datastream(ActiveFedora::Datastream, 'ARTICLE', article)
        object.add_datastream(ds)
      }

      it { should be_kind_of Text }
    end

    context "when it can't determine the type of object" do
      it { should be_kind_of Text }
    end

  end  # build_work
end
