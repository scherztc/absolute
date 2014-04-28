# Generated via
#  `rails generate curate:work Text`
require 'spec_helper'

describe CurationConcern::TextsController do
  it_behaves_like 'is_a_curation_concern_controller', Text, actions: :all
end
