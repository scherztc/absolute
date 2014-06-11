module FacetHelper

  def display_collection(val)
    obj = ActiveFedora::SolrService.query(ActiveFedora::SolrService.construct_query_for_pids([val])).first
    obj["desc_metadata__title_tesim"].first if obj
  end

  # Convert a 2 or 3 letter (ISO-639-1 or ISO-639-3) code to language name
  def display_language(val)
    LanguageList::LanguageInfo.find(val).name
  end
end
