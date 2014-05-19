require 'spec_helper'

describe ThumbnailHelper do
  
  describe 'document_thumbnail_tag' do
    let(:html_params) { return {width: 36, class: "canonical-image"} }
    it "should display a thumbnail from the representative_image_url when available" do
      path = "/foo/thumbnail.png"
      helper.should_receive(:image_tag).with(path, html_params )
      helper.document_thumbnail_tag(double(representative_image_url:path))
    end
    it "should return a default icon appropriate for the type of document" do
      # Known Types with Icons
      [Image, Audio, Video, Text].each do |klass|
        helper.should_receive(:image_tag).with("#{klass.to_s}.png", html_params )
        helper.document_thumbnail_tag(klass.new)
      end
      # Other
      [Collection, CaseGenericWork].each do |klass|
        helper.should_receive(:image_tag).with("Other.png", html_params )
        helper.document_thumbnail_tag(klass.new)
      end
    end
  end
  describe 'generic_file_thumbnail_tag' do
    let(:html_params) { return {width: 36, class: "thumbnail"} }
    let(:generic_file) { GenericFile.new() }
    let(:download_path) { "thumbnail/path.png" }
    before { helper.stub(:download_path).with(generic_file, {datastream_id: 'thumbnail'}) {download_path} }
    it "should show the thumbnail for pdfs" do
      generic_file.stub(:mime_type) {'application/pdf'}      
      helper.should_receive(:image_tag).with(download_path, html_params )
      helper.generic_file_thumbnail_tag(generic_file)
    end
    it "should show the thumbnail for images" do
      generic_file.stub(:image?) {true}
      helper.should_receive(:image_tag).with(download_path, html_params )
      helper.generic_file_thumbnail_tag(generic_file)
    end
    it "should show the icon for audio" do
      generic_file.stub(:audio?) {true}
      helper.should_receive(:image_tag).with("Audio.png", html_params )
      helper.generic_file_thumbnail_tag(generic_file)
    end
    it "should show the icon for video" do
      generic_file.stub(:video?) {true}
      helper.should_receive(:image_tag).with("Video.png", html_params )
      helper.generic_file_thumbnail_tag(generic_file)
    end
    it "should show default icon for file types that dont have icons" do
      # Default
      helper.should_receive(:image_tag).with("Other.png", html_params )
      helper.generic_file_thumbnail_tag(generic_file)
    end

  end
end
