class SubmitController < ApplicationController
  include Worthwhile::ThemedLayoutController
  with_themed_layout '1_column'

  def index
  end

  # Load files
  def submit

    redirect_to '/submit/thanks'
  end

  def thanks
  end
end
