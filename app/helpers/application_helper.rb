module ApplicationHelper
  include Worthwhile::MainAppHelpers
  include ThumbnailHelper
  include FullRecordXmlHelper

  def admin?
    current_user && current_user.admin?
  end
end
