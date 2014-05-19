# Generated via
#  `rails generate curate:work Video`

class CurationConcern::ImagesController < ApplicationController
  include Worthwhile::CurationConcernController
  helper Openseadragon::OpenseadragonHelper
  set_curation_concern_type Image
end
