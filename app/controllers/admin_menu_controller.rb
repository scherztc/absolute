class AdminMenuController < ApplicationController
  include Worthwhile::ThemedLayoutController
  with_themed_layout '1_column'

  def show
    authorize! :read, :admin_menu
  end

end
