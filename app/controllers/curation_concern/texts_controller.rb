class CurationConcern::TextsController < ApplicationController
  include Worthwhile::CurationConcernController
  set_curation_concern_type Text
end
