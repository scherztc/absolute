# Generated via
#  `rails generate curate:work Audio`
require 'spec_helper'
require 'active_fedora/test_support'

describe Audio do
  include ActiveFedora::TestSupport
  subject { Audio.new }

  it_behaves_like 'is_a_curation_concern_model'
  it_behaves_like 'with_access_rights'
  it_behaves_like 'is_embargoable'
  it_behaves_like 'has_dc_metadata'

end
