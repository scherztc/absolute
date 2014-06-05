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

  before { stub_out_dc_parser }


  describe 'importing an object with a PID that already exists' do
    let(:text) { FactoryGirl.build(:text) }

    it 'raises an error' do
      expect(ActiveFedora::Base).to receive(:exists?).and_return(true) 
      expect {
        WorkFactory.new(text).build_work
      }.to raise_error(PidAlreadyInUseError)
    end
  end


  describe 'build_work:' do
    before { stub_out_set_pid }

    context 'the source object contains an MPG datastream' do
      let(:video) {
        obj = FactoryGirl.build(:text)
        obj.add_file_datastream('pdf content', pdf)
        obj.add_file_datastream('mpg content', mpg)
        obj
      }

      it 'returns a Video work' do
        new_object = WorkFactory.new(video).build_work
        expect(new_object).to be_new_record
        expect(new_object.class).to eq Video
      end
    end

    context 'the source object contains a WAV datastream' do
      let(:audio) {
        obj = FactoryGirl.build(:text)
        obj.add_file_datastream('wav content', wav)
        obj
      }

      it 'returns an Audio work' do
        expect(WorkFactory.new(audio).build_work.class).to eq Audio
      end
    end

    context 'the source object contains a MP3 datastream' do
      let(:audio) {
        obj = FactoryGirl.build(:text)
        obj.add_file_datastream('mp3 content', mp3)
        obj
      }

      it 'returns an Audio work' do
        expect(WorkFactory.new(audio).build_work.class).to eq Audio
      end
    end

    context 'the source object contains both audio and video datastreams' do
      let(:object) {
        obj = FactoryGirl.build(:text)
        obj.add_file_datastream('pdf content', pdf)
        obj.add_file_datastream('mpg content', mpg)
        obj.add_file_datastream('mp3 content', mp3)
        obj
      }

      it 'returns a Video work' do
        expect(WorkFactory.new(object).build_work.class).to eq Video
      end
    end

    context 'the source object contains TEI datastreams' do
      let(:object) {
        obj = FactoryGirl.build(:text)
        obj.add_file_datastream('pdf content', pdf)
        obj.add_file_datastream('tei content', tei)
        obj
      }

      it 'returns a Text work' do
        expect(WorkFactory.new(object).build_work.class).to eq Text
      end
    end

    context 'the source object contains both TEI and MP3 datastreams' do
      let(:object) {
        obj = FactoryGirl.build(:text)
        obj.add_file_datastream('pdf content', pdf)
        obj.add_file_datastream('tei content', tei)
        obj.add_file_datastream('mp3 content', mp3)
        obj
      }

      it 'returns an Audio work' do
        expect(WorkFactory.new(object).build_work.class).to eq Audio
      end
    end

    context 'the source object contains GIF datastream' do
      let(:object) {
        obj = FactoryGirl.build(:image)
        obj.add_file_datastream('pdf content', pdf)
        obj.add_file_datastream('gif content', gif)
        obj
      }

      it 'returns an Image work' do
        expect(WorkFactory.new(object).build_work.class).to eq Image
      end
    end

    context 'the source object contains both image and TEI' do
      let(:object) {
        obj = FactoryGirl.build(:text)
        obj.add_file_datastream('gif content', gif)
        obj.add_file_datastream('tei content', tei)
        obj
      }

      it 'returns a Text work' do
        expect(WorkFactory.new(object).build_work.class).to eq Text
      end
    end

    context 'the source object contains a PDF datastream' do
      let(:object) {
        obj = FactoryGirl.build(:audio)
        obj.add_file_datastream('pdf content', pdf)
        obj
      }

      it 'returns a Text work' do
        expect(WorkFactory.new(object).build_work.class).to eq Text
      end
    end

    context 'the source object has a link called "VIDEO"' do
      let(:object) {
        obj = FactoryGirl.build(:audio)
        ds = obj.create_datastream(ActiveFedora::Datastream, 'VIDEO', video)
        obj.add_datastream(ds)
        obj
      }

      it 'returns a Video work' do
        expect(WorkFactory.new(object).build_work.class). to eq Video
      end
    end

    context 'the source object has a link called "ARTICLE"' do
      let(:object) {
        obj = FactoryGirl.build(:audio)
        ds = obj.create_datastream(ActiveFedora::Datastream, 'ARTICLE', article)
        obj.add_datastream(ds)
        obj
      }

      it 'returns a Text work' do
        expect(WorkFactory.new(object).build_work.class).to eq Text
      end
    end

    context "when it can't determine the type of object" do
      let(:object) { FactoryGirl.build(:audio) }

      it 'returns a generic work' do
        expect(WorkFactory.new(object).build_work.class).to eq CaseGenericWork
      end
    end

  end  # build_work


  # Don't try to parse the DC datastream for these tests
  def stub_out_dc_parser
    allow_any_instance_of(DcParser).to receive(:from_xml) { '' }
    allow_any_instance_of(DcParser).to receive(:to_attrs_hash) {
      { title: 'Stubbed Title', rights: 'Stubbed Rights' }
    }
  end

end
