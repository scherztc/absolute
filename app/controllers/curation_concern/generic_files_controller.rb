module CurationConcern
  class GenericFilesController < ApplicationController
    include Worthwhile::FilesController
    helper Openseadragon::OpenseadragonHelper
  end
end

