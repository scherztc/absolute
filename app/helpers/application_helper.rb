module ApplicationHelper
  include Worthwhile::MainAppHelpers
  include ThumbnailHelper
  include FacetHelper
  include FullRecordXmlHelper
  include WorthwhileHelper

  def admin?
    current_user && current_user.admin?
  end

  # This method overrides the method from
  # Blacklight::BlacklightHelperBehavior
  def presenter_class
    ::ShowMorePresenter
  end

end
