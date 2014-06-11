require 'spec_helper'

describe ThumbnailHelper do
  
  describe 'thumbnail_tag' do
    let(:work) { GenericWork.new }
    let(:document) { SolrDocument.new work.to_solr }

    context "when the representative is set" do
      let(:path) { "ksl:test123" }
      before do
        allow(document).to receive(:representative).and_return(path)
      end

      it "displays a thumbnail" do
        expect(helper).to receive(:image_tag).with("/downloads/ksl:test123?datastream_id=thumbnail", {:alt=>"Thumbnail", :class=>"canonical-image"})
        helper.thumbnail_tag(document, {})
      end

      context "for an Audio" do
        let(:work) { Audio.new }
        it "returns a default icon" do
          expect(helper).to receive(:image_tag).with("Audio.png", class: "canonical-image" )
          helper.thumbnail_tag(document, {} )
        end
      end
    end
    
    context "for an Image" do
      let(:work) { Image.new }
      it "returns a default icon" do
        expect(helper).to receive(:image_tag).with("Image.png", class: "canonical-image" )
        helper.thumbnail_tag(document, {} )
      end
    end

    context "for an Audio" do
      let(:work) { Audio.new }
      it "returns a default icon" do
        expect(helper).to receive(:image_tag).with("Audio.png", class: "canonical-image" )
        helper.thumbnail_tag(document, {} )
      end
    end
    context "for an Video" do
      let(:work) { Video.new }
      it "returns a default icon" do
        expect(helper).to receive(:image_tag).with("Video.png", class: "canonical-image" )
        helper.thumbnail_tag(document, {} )
      end
    end
    context "for an Text" do
      let(:work) { Text.new }
      it "returns a default icon" do
        expect(helper).to receive(:image_tag).with("Text.png", class: "canonical-image" )
        helper.thumbnail_tag(document, {} )
      end
    end
    context "for an Collection" do
      let(:work) { Collection.new }
      it "returns a default icon" do
        expect(helper).to receive(:image_tag).with("Other.png", class: "canonical-image" )
        helper.thumbnail_tag(document, {} )
      end
    end
    context "for an CaseGenericWork" do
      let(:work) { CaseGenericWork.new }
      it "returns a default icon" do
        expect(helper).to receive(:image_tag).with("Other.png", class: "canonical-image" )
        helper.thumbnail_tag(document, {} )
      end
    end
  end

  describe 'generic_file_thumbnail_tag' do
    let(:html_params) { return {width: 90, class: "thumbnail"} }
    let(:generic_file) { GenericFile.new() }
    let(:download_path) { "thumbnail/path.png" }
    before { allow(helper).to receive(:download_path).with(generic_file, {datastream_id: 'thumbnail'}) {download_path} }
    it "should show the thumbnail for pdfs" do
      allow(generic_file).to receive(:mime_type) {'application/pdf'}      
      expect(helper).to receive(:image_tag).with(download_path, html_params )
      helper.generic_file_thumbnail_tag(generic_file)
    end
    it "should show the thumbnail for images" do
      allow(generic_file).to receive(:image?) {true}
      expect(helper).to receive(:image_tag).with(download_path, html_params )
      helper.generic_file_thumbnail_tag(generic_file)
    end
    it "should show the icon for audio" do
      allow(generic_file).to receive(:audio?) {true}
      expect(helper).to receive(:image_tag).with("Audio.png", html_params )
      helper.generic_file_thumbnail_tag(generic_file)
    end
    it "should show the icon for video" do
      allow(generic_file).to receive(:video?) {true}
      expect(helper).to receive(:image_tag).with("Video.png", html_params )
      helper.generic_file_thumbnail_tag(generic_file)
    end
    it "should show default icon for file types that dont have icons" do
      # Default
      expect(helper).to receive(:image_tag).with("Other.png", html_params )
      helper.generic_file_thumbnail_tag(generic_file)
    end

  end
end
