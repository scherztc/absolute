require 'spec_helper'

describe Text do
  it_behaves_like 'is_a_curation_concern_model'
  it_behaves_like 'with_access_rights'
  it_behaves_like 'is_embargoable'
  it_behaves_like 'has_dc_metadata'

  # TODO: This is the test you will use when we add handle support
  # it_behaves_like 'remotely_identified', :handle

  its(:tei?) { should_not be_present }

  context "with TEI" do
    before do
      Text.destroy_all
      document.add_file(File.open(fixture_path + '/files/anoabo00-TEI.xml').read, 'TEIP5', 'A TEI file')
    end
    let(:document) { Text.new(pid: 'sufia:anoabo00') }

    subject { document } 

    its(:tei?) { should be_present }

    describe 'tei_to_html' do
      let(:html) { document.tei_to_html }
      subject { Nokogiri::HTML(html) }

      before do
        allow(document).to receive(:id_for_filename).and_return("sufia:0001")
      end

      it "has 25 rows" do
        expect(html).to be_html_safe
        expect(subject.css('#tei-content').attr('data-max-pages').value).to eq '25'
        expect(subject.css('.row').size).to eq 25
        expect(subject.css('#page-1.row img').first.attr('src')).to eq '/image-service/sufia:0001/full/,600/0/native.jpg'
      end

      context "with errors" do
        before do
          allow_any_instance_of(Nokogiri::HTML::Document).to receive(:css).with('#tei-content').and_return([])
        end
        it "draws an error" do
          expect(html).to eq "<div id=\"tei-content\"><div class=\"alert alert-danger\">Unable to parse TEI datastream for this object.</div></div>"
          expect(html).to be_html_safe
        end
      end
    end

    describe 'id_for_filename' do
      before do
        document.save(validate: false)
      end
      let!(:file) do
        Worthwhile::GenericFile.new(batch_id: document.id).tap do |file|
          file.add_file(File.open(fixture_path + '/files/anoabo00-00001.jp2', 'rb').read, 'content', 'anoabo00-00001.jp2')
          file.apply_depositor_metadata('jmc')
          file.save!
        end
      end
      it "returns the path of the file" do
        expect(document.id_for_filename('anoabo00-00001.jp2')).to eq file.pid
      end
    end

    describe 'to_solr' do
      subject { document.to_solr }
      its(['datastreams_ssim']) { should eq ['TEIP5'] }

      context "when a member of several collections" do
        before do 
          Collection.destroy_all
          document.attributes = FactoryGirl.attributes_for(:text)
        end
        let(:collection) { FactoryGirl.create(:collection, members: [document]) }
        its (['collection_sim']) { should eq [collection.pid] }
      end
    end
  end
end
