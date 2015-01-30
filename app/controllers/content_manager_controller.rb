class ContentManagerController < ApplicationController
  include Worthwhile::ThemedLayoutController
  with_themed_layout '1_column'

  authorize_resource class: false

  def index
  end

end
