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

  # A helper method so that Blacklight will display a link to the source if
  # if it is a valid url. Can be used as a substitued to Worthwile's
  # curation_concern_attribute_to_html
  def curation_concern_with_link_to_html(curation_concern, method_name, label = nil)
    markup = String.new
    if curation_concern.respond_to?(method_name)
      label ||= derived_label_for(curation_concern, method_name)
      subject = curation_concern.send(method_name)
      return markup if !subject.present?
      markup <<  %(<tr><th>#{label}</th>\n<td><ul class='tabular'>)
      [subject].flatten.compact.each do |value|
        # If the field value is a url, we wrap it in an anchor tag
        li_value = link_to_if(h(value) =~ URI::regexp, h(value), h(value), target: "_blank")
        markup << %(<li class="attribute #{method_name}"> #{li_value} </li>\n)
      end
    end
    markup << %(</ul></td></tr>)
    markup.html_safe
  end


  ##
  # TODO remove with blacklight 5.5 (projectblacklight/blacklight#933)
  # Renders the list of values 
  # removes any elements where render_facet_item returns a nil value. This enables an application
  # to filter undesireable facet items so they don't appear in the UI
  def render_facet_limit_list(paginator, solr_field, wrapping_element=:li)
    safe_join(paginator.items.
      map { |item| render_facet_item(solr_field, item) }.compact.
      map { |item| content_tag(wrapping_element,item)}
    )
  end

  ##
  # TODO remove with blacklight 5.5 (projectblacklight/blacklight#933)
  # Renders a single facet item
  def render_facet_item(solr_field, item)
    if facet_in_params?( solr_field, item.value )
      render_selected_facet_value(solr_field, item)          
    else
      render_facet_value(solr_field, item)
    end
  end

  ## Override blacklight so we don't display the "Type of Work" when the only item is "Collections" which is hidden.
  def should_render_facet?(display_facet)
    return false if display_facet.name == 'human_readable_type_sim' && display_facet.items.reject { |item| item.value == 'Collection'}.empty?
    super
  end
end
