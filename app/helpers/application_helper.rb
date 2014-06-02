module ApplicationHelper
  include Worthwhile::MainAppHelpers
  include ThumbnailHelper
  include FullRecordXmlHelper

  def admin?
    current_user && current_user.admin?
  end

  def display_collection(val)
    obj = ActiveFedora::SolrService.query(ActiveFedora::SolrService.construct_query_for_pids([val])).first
    obj["desc_metadata__title_tesim"].first
  end
end
