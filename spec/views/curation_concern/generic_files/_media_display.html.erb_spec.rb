require 'spec_helper'

describe "curation_concern/generic_files/_media_display.html.erb" do
  before do
    view.stub(:generic_file).and_return(generic_file)
  end
  context "for an image" do
    let(:generic_file) { double(id: 'abc123', image?: true) }

    it "displays openseadragon" do
      expect(view).to receive(:openseadragon_picture_tag).with('/image-service/abc123/info.json', data: { openseadragon: 
        "{\"prefixUrl\":\"\",\"navImages\":{\"zoomIn\":{\"REST\":\"/assets/openseadragon/zoomin_rest.png\",\"GROUP\":\"/assets/openseadragon/zoomin_grouphover.png\",\"HOVER\":\"/assets/openseadragon/zoomin_hover.png\",\"DOWN\":\"/assets/openseadragon/zoomin_pressed.png\"},\"zoomOut\":{\"REST\":\"/assets/openseadragon/zoomout_rest.png\",\"GROUP\":\"/assets/openseadragon/zoomout_grouphover.png\",\"HOVER\":\"/assets/openseadragon/zoomout_hover.png\",\"DOWN\":\"/assets/openseadragon/zoomout_pressed.png\"},\"home\":{\"REST\":\"/assets/openseadragon/home_rest.png\",\"GROUP\":\"/assets/openseadragon/home_grouphover.png\",\"HOVER\":\"/assets/openseadragon/home_hover.png\",\"DOWN\":\"/assets/openseadragon/home_pressed.png\"},\"fullpage\":{\"REST\":\"/assets/openseadragon/fullpage_rest.png\",\"GROUP\":\"/assets/openseadragon/fullpage_grouphover.png\",\"HOVER\":\"/assets/openseadragon/fullpage_hover.png\",\"DOWN\":\"/assets/openseadragon/fullpage_pressed.png\"},\"rotateleft\":{\"REST\":\"/images/openseadragon/rotateleft_rest.png\",\"GROUP\":\"/images/openseadragon/rotateleft_grouphover.png\",\"HOVER\":\"/images/openseadragon/rotateleft_hover.png\",\"DOWN\":\"/images/openseadragon/rotateleft_pressed.png\"},\"rotateright\":{\"REST\":\"/images/openseadragon/rotateright_rest.png\",\"GROUP\":\"/images/openseadragon/rotateright_grouphover.png\",\"HOVER\":\"/images/openseadragon/rotateright_hover.png\",\"DOWN\":\"/images/openseadragon/rotateright_pressed.png\"},\"previous\":{\"REST\":\"/assets/openseadragon/previous_rest.png\",\"GROUP\":\"/assets/openseadragon/previous_grouphover.png\",\"HOVER\":\"/assets/openseadragon/previous_hover.png\",\"DOWN\":\"/assets/openseadragon/previous_pressed.png\"},\"next\":{\"REST\":\"/assets/openseadragon/next_rest.png\",\"GROUP\":\"/assets/openseadragon/next_grouphover.png\",\"HOVER\":\"/assets/openseadragon/next_hover.png\",\"DOWN\":\"/assets/openseadragon/next_pressed.png\"}}}"
      }).and_return("<picture>".html_safe)
      render
      expect(rendered).to match /<picture>/ 

    end
  end
end
