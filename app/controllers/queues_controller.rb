# This page is only loaded when a user is denied access to the Resque Dashboard.  It uses CanCan's authorize to display a flash message to inform the user they were denied access.
class QueuesController < ApplicationController
  include Worthwhile::ThemedLayoutController
  with_themed_layout '1_column'

  def show
    authorize! :read, :queues
  end

end
