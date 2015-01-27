class ShowMorePresenter < Blacklight::DocumentPresenter

  # This class overrides some of the presenter methods from
  # Blacklight::DocumentPresenter so that we can include a
  # toggle to truncate and show/hide long descriptions.

  def max_length
    150
  end

  def render_index_field_value(field, options = {})
    field_config = @configuration.index_fields[field]
    value = options[:value] || get_field_values(field, field_config, options)

    # Replace ISO 639 codes with the language name
    if field == 'desc_metadata__language_tesim'
      value.each do |val|
        lang = LanguageList::LanguageInfo.find(val)
        value -= [val]
        value << lang.name
      end
    end

    if truncate_field?(field, value)
      render_truncated_field_value(value, field_config)
    else
      render_field_value(value, field_config)
    end
  end

  def truncate_field?(field, value)
    length = Array(value).inject(0) {|sum, v| sum = sum + v.length }
    field == 'desc_metadata__description_tesim' && length > max_length
  end

  def render_truncated_field_value(value=nil, field_config=nil)
    safe_values = Array(value).collect { |x| x.respond_to?(:force_encoding) ? x.force_encoding("UTF-8") : x }

    long_value = safe_values.join(', ')
    short_value = long_value.truncate(max_length - 30)

    long_field = content_tag(:div, long_value, class: 'show-less')
    short_field = content_tag(:div, short_value, class: 'show-more')

    show_less = content_tag(:div, 'show less', class: 'show-less link-style')
    show_more = content_tag(:div, 'show more', class: 'show-more link-style')

    safe_join([short_field, show_more, long_field, show_less], ' ')
  end 

end
