require 'spec_helper'

describe ShowMorePresenter do
  let(:blacklight_helper) {
    double(blacklight_config: double(index_fields: {}) )
  }

  subject { ShowMorePresenter.new('', blacklight_helper) }

  describe '#render_index_field_value' do
    let(:desc_field) { 'desc_metadata__description_tesim' }

    context 'if the description field is short' do
      let(:short_desc) { 'A short description' }

      it 'does not truncate the field' do
        expect(subject).to receive(:render_field_value)
        subject.render_index_field_value(desc_field, { value: short_desc })
      end
    end

    context 'if the description field is too long' do
      let(:long_desc) { 'And as for those who, previously hearing of the White Whale, by chance caught sight of him; in the beginning of the thing they had every one of them, almost, as boldly and fearlessly lowered for him, as for any other whale of that species. But at length, such calamities did ensue in these assaults-not restricted to sprained wrists and ankles, broken limbs, or devouring amputations-but fatal to the last degree of fatality; those repeated disastrous repulses, all accumulating and piling their terrors upon Moby Dick; those things had gone far to shake the fortitude of many brave hunters, to whom the story of the White Whale had eventually come.' } 

      it 'truncates the description' do
        expect(subject).to receive(:render_truncated_field_value)
        subject.render_index_field_value(desc_field, { value: long_desc })
      end

      it 'has the elements needed by the javascript' do
        elements = subject.render_truncated_field_value(long_desc)
        html = Nokogiri::HTML::Document.parse(elements)

        short_desc = html.xpath("//div[@class='show-more']").first
        beginning = long_desc.chars.slice(0, 50).join('')
        expect(short_desc.text).to match beginning

        desc = html.xpath("//div[@class='show-less']").first
        expect(desc.text).to eq long_desc

        show_more = html.xpath("//div[@class='show-more link-style']").first
        expect(show_more.text).to eq 'show more'

        show_less = html.xpath("//div[@class='show-less link-style']").first
        expect(show_less.text).to eq 'show less'
      end
    end

    context 'if there are multiple descriptions that become too long' do
      let(:desc1) { "Biographies of scholars without exhibit images " }
      let(:desc2) { "Dr. Leroy Bundy, Class of 1903. Dr. Bundy graduated from the Western Reserve University Dental School but did not open an office. Instead, he worked for the Woodcliff Dentists, an advertising dental office. He later made several unsuccessful attempts to establish offices in Detroit and Chicago and finally settled in St. Louis. Eventually, Dr. Bundy returned to Cleveland and established a practice. In 1930, he entered politics and was elected to the City Council, a position he held for ten years." }
      let(:long_desc) { [desc1, desc2] }

      it 'truncates the field' do
        expect(subject).to receive(:render_truncated_field_value)
        subject.render_index_field_value(desc_field, { value: long_desc })
      end

    end
  end

end
