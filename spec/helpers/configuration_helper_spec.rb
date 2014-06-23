require 'spec_helper'

describe BlacklightConfigurationHelper do

  describe "creator facet" do
    before do
      allow(helper).to receive(:blacklight_config).and_return(CatalogController.blacklight_config)
    end
    let(:field) { 'desc_metadata__creator_sim' }
    subject { helper.facet_field_label field }
    it { should eq 'People' }
  end
end
