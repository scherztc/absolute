class UploadController < ApplicationController
  include Worthwhile::ThemedLayoutController

  def index
  end

  def ingest


    render action: "index"
  end
end
