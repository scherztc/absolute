require 'spec_helper'

describe FacetHelper do
  describe "#display_collection" do
    let(:collection) { FactoryGirl.create(:collection, title: "Test title") }
    subject { helper.display_collection(collection.id) }
    it { should eq "Test title"}
  end
  
  describe '#display_language' do
    context 'with a real language' do
      subject { helper.display_language('eng') }
      it { should eq 'English'}
    end
    context 'with garbage' do
      subject { helper.display_language('blhearg') }
      it { should eq 'blhearg'}
    end
  end

  describe 'render_facet_value' do
    let(:field) { 'human_readable_type_sim' }
    let(:item) { Blacklight::SolrResponse::Facets::FacetItem.new value: item_value, hits: 1 }
    subject { helper.render_facet_value(field, item) }
    before do
      allow(helper).to receive(:search_action_path) do |*args|
        catalog_index_path *args
      end
    end

    context 'when field is Type of Work and item is Collection' do
      let(:item_value) { 'Collection' }
      it { should be_nil}
    end

    context 'when field is Type of Work and item is not Collection' do
      let(:item_value) { 'Text' }

      it { should eq "<span class=\"facet-label\"><a class=\"facet_select\" href=\"/catalog?f%5Bhuman_readable_type_sim%5D%5B%5D=Text\">Text</a></span><span class=\"facet-count\">1</span>" }
    end

  end

  describe '#find_case' do
    context 'when subject is uppercase' do
      subject { helper.find_case('never') }
      it { should eq "Never" }
    end
    context 'when subject is lowercase' do
      subject {helper.find_case('gonna') }
      it { should eq 'gonna' }
    end
    before do
      GenericWork.create!(pid: "rick:123", title: ["Let's Roll"], subject: ["Never", "gonna", "give", "you", "Up"])
    end
  end
  
  describe '#curation_concern_with_link_to_html' do
    context 'when field not a valid url' do
      let(:regular_source) { GenericWork.create!(pid: "me:123", title: ["Just a Test"], source: ["National Geographic"]) }
      subject {helper.curation_concern_with_link_to_html(regular_source, :source, "Source") }
      it { should eq "<tr><th>Source</th>\n<td><ul class='tabular'><li class=\"attribute source\"> National Geographic </li>\n</ul></td></tr>"}
    end

    context 'when field is a valid url' do
      let(:regular_source) { GenericWork.create!(pid: "me:456", title: ["Just a Test"], source: ["http://library.case.edu"]) }
      subject { helper.curation_concern_with_link_to_html(regular_source, :source, "Source") }
      it { should eq "<tr><th>Source</th>\n<td><ul class='tabular'><li class=\"attribute source\"> <a href=\"http://library.case.edu\" target=\"_blank\">http://library.case.edu</a> </li>\n</ul></td></tr>"}
    end

    context 'when field is null' do
      subject { helper.curation_concern_with_link_to_html(nil, :source, "Source") }
      it { should eq nil}
    end

  end

  describe "should_render_facet?" do

    let(:facet) { Blacklight::SolrResponse::Facets::FacetField.new field, [item] }
    let(:field) { 'human_readable_type_sim' }
    let(:item) { Blacklight::SolrResponse::Facets::FacetItem.new value: item_value, hits: 1 }
    subject { helper.should_render_facet?(facet) }
    context 'when field is Type of Work and item is Collection' do
      let(:item_value) { 'Collection' }
      it { should be false }
    end

    context 'when field is Type of Work and item is not Collection' do
      let(:item_value) { 'Text' }

      it { should be true }
    end
  end
end
