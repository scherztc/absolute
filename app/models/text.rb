class Text < ActiveFedora::Base
  include CurationConcern::CaseWork
  include ActionView::Helpers::AssetTagHelper
  
  self.human_readable_short_description = "Any Text work, preferably with TEI xml attached."  
  self.accept_datastream_attachments ["TEI", "TEIP5", "MODS", "METS", "QDC"]
  
  def tei?
    datastreams['TEIP5'].has_content?
  end

  def tei_as_json
    # First parsing will just mark up page breaks
    doc = Nokogiri::XML(datastreams['TEIP5'].content)
    xslt = Nokogiri::XSLT(File.read('lib/stylesheets/tei.xslt'))
    intermediate = xslt.transform(doc).to_xml

    # second parsing will put the text between each break into divs
    doc2 = Nokogiri::HTML(intermediate)
    root = doc2.css('#tei-content').first
    return {error: "Unable to parse TEI datastream for this object."} if root.nil?
    pages = [ ]
    current_element = {html: '' }
    page = 1
    root.children.each do |e|
      case e
      when Nokogiri::XML::Text
        next if e.to_s.strip == ''
        current_element[:html] << "<div>#{e.to_s}</div>".html_safe
      when Nokogiri::XML::Element
        # if the element is a page break. Add an image and a text blurb.
        next if e.name == 'br'
        if e.attr('class') == "pageheader"
          pages << current_element if page > 1
          current_element = {page: page, html: ''.html_safe}
          page += 1
          file_id = id_for_filename(e.attr('data-image'))
          current_element[:image] = image_tag(Riiif::Engine.routes.url_helpers.image_path(file_id, size: ',600')) if file_id
        end
        resolve_image_paths!(e)
        current_element[:html] << e.to_s.html_safe
      end
    end
    pages << current_element
    {pages: pages, object: root.attr('data-object')}.with_indifferent_access
  end


  # For any inlined figure translate data-image attributes into iiif urls in the src attribute
  def resolve_image_paths!(e)
    e.css('figure > img').each do |image|
      file_id = id_for_filename(image.attr('data-image'))
      image.set_attribute('src', Riiif::Engine.routes.url_helpers.image_path(file_id, size: 'full')) if file_id
    end
  end


  def id_for_filename(filename)
    result = Worthwhile::GenericFile.where(is_part_of_ssim: self.internal_uri, desc_metadata__title_sim: filename).first
    result && result.id
  end
end
