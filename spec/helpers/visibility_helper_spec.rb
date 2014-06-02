require 'spec_helper'

describe VisibilityHelper do

  let(:auth) { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED }
  let(:pub) { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
  let(:priv) { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE }

  describe 'human_readable_visibility' do

    it 'returns a human-friendly string for authenticated visibility' do
      expect(helper.human_readable_visibility(auth)).to eq 'Case Western Reserve University'
    end

    it 'returns visibility for public or private' do
      expect(helper.human_readable_visibility(priv)).to eq priv
      expect(helper.human_readable_visibility(pub)).to eq pub
    end
  end

end

