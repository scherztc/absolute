# Generated via
#  `rails generate curate:work Video`

class CurationConcern::ImagesController < ApplicationController
  include Worthwhile::CurationConcernController
  set_curation_concern_type Image
end
