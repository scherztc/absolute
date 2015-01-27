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

  # This helper overrides worthwhiles curation_concern_attrubyte_to_html function
  # to allow for rewriting ISO 639 language codes as the language name instead
  # of the languages code
  def language_to_html(curation_concern, method_name, label = nil, options = {})
    markup = ""
    label ||= derived_label_for(curation_concern, method_name)
    subject = curation_concern.send(method_name)
    return markup if !subject.present? && !options[:include_empty]
    markup << %(<tr><th>#{label}</th>\n<td><ul class='tabular'>)
    [subject].flatten.compact.each do |value|
      lang = LanguageList::LanguageInfo.find(value)
      markup << %(<li class="attribute #{method_name}">#{h( lang ? lang.name : value )}</li>\n)
    end
    markup << %(</ul></td></tr>)
    markup.html_safe
  end

end
