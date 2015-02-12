module FacetHelper

  def display_collection(val)
    obj = ActiveFedora::SolrService.query(ActiveFedora::SolrService.construct_query_for_pids([val])).first
    obj["desc_metadata__title_tesim"].first if obj
  end

  # Convert a 2 or 3 letter (ISO-639-1 or ISO-639-3) code to language name
  def display_language(val)
    lang = LanguageList::LanguageInfo.find(val)
    lang ? lang.name : val
  end

  # Override Blacklight so that we don't show anything for collections.
  def render_facet_value(facet_solr_field, item, options ={})
    return if facet_solr_field == 'human_readable_type_sim' && item.value == 'Collection'
    super
  end

  # Helper method to display correct case of subject facets.
  # Queries given an all lower case facet, queries solr for the correctly cased one and displays that.
  def find_case(value)
    query = remote_solr.get('select', params: {q: "subject_sort:\"#{value}\"", fl: 'desc_metadata__subject_tesim', rows: 1})
    if query['response']['docs'].any?
      subjects =  query['response']['docs'][0]['desc_metadata__subject_tesim']
      subject = subjects.select { |s| s.downcase.include? value}
      value = subject[0]
    end
  end

  # A helper method so that Blacklight will display a link to the source if
  # if it is a valid url. Can be used as a substitued to Worthwile's
  # curation_concern_attribute_to_html
  def curation_concern_with_link_to_html(curation_concern, method_name, label = nil)
    if curation_concern.respond_to?(method_name)
      markup = String.new
      label ||= derived_label_for(curation_concern, method_name)
      subject = curation_concern.send(method_name)
      return markup if !subject.present?
      markup <<  %(<tr><th>#{label}</th>\n<td><ul class='tabular'>)
      [subject].flatten.compact.each do |value|
        # If the field value is a url, we wrap it in an anchor tag
        li_value = link_to_if(h(value) =~ URI::regexp, h(value), h(value), target: "_blank")
        markup << %(<li class="attribute #{method_name}"> #{li_value} </li>\n)
      end
      markup << %(</ul></td></tr>)
      markup.html_safe
    end
  end


  ## Override blacklight so we don't display the "Type of Work" when the only item is "Collections" which is hidden.
  def should_render_facet?(display_facet)
    return false if display_facet.name == 'human_readable_type_sim' && display_facet.items.reject { |item| item.value == 'Collection'}.empty?
    super
  end
end
