# Generated via
#  `rails generate curate:work Text`
require 'spec_helper'
require 'active_fedora/test_support'

describe Text do
  include ActiveFedora::TestSupport
  subject { Text.new }

  it_behaves_like 'is_a_curation_concern_model'
  it_behaves_like 'with_access_rights'
  it_behaves_like 'is_embargoable'
  it_behaves_like 'has_dc_metadata'
  # TODO: This is the test you will use when we add handle support
  # it_behaves_like 'remotely_identified', :handle
  #

end
