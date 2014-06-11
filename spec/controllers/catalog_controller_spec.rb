require 'spec_helper'

describe CatalogController do
  describe "#index" do
    context "when no search params are entered" do
      before do
        Collection.destroy_all
      end

      let!(:collection) { FactoryGirl.create(:public_collection) }
      let!(:private_collection) { FactoryGirl.create(:private_collection) }
      let!(:work) { FactoryGirl.create(:image) }

      it "shows public collections" do
        get :index
        expect(response).to be_successful
        expect(assigns(:document_list).map(&:id)).to match_array([collection.id])
      end
    end
  end

  describe "facets" do
    subject { CatalogController.blacklight_config.facet_fields.keys }
    it { should include('datastreams_ssim', 'collection_sim') }
  end

  describe "language facet" do
    subject { CatalogController.blacklight_config.facet_fields['desc_metadata__language_sim'] }
    its(:helper_method) { should eq :display_language }
  end
end
