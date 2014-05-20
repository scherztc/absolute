class Text < ActiveFedora::Base
  include CurationConcern::Work
  include CurationConcern::CaseWork
  include ActionView::Helpers::AssetTagHelper
  
  self.human_readable_short_description = "Any Text work, preferably with TEI xml attached."  
  self.accept_datastream_attachments ["TEI", "TEIP5", "MODS", "METS", "QDC"]
  
  validates_presence_of :rights, message: 'You must select a license for your work.'

  has_metadata "descMetadata", type: GenericWorkRdfDatastream

  def tei?
    datastreams['TEIP5'].has_content?
  end

  def tei_to_html
    # First parsing will just mark up page breaks
    doc = Nokogiri::XML(datastreams['TEIP5'].content)
    xslt = Nokogiri::XSLT(File.read('lib/stylesheets/tei.xslt'))
    intermediate = xslt.transform(doc).to_xml


    # second parsing will put the text between each break into divs
    doc2 = Nokogiri::HTML(intermediate)
    root = doc2.css('#tei-content').first
    return "<div id=\"tei-content\"><div class=\"alert alert-danger\">Unable to parse TEI datastream for this object.</div></div>".html_safe if root.nil?
    out = "<div id=\"tei-content\" data-object=\"#{root.attr('data-object') }\">"
    in_row = false
    page = 1
    doc2.css('#tei-content').first.children.each do |e|
      case e
      when Nokogiri::XML::Text
        next if e.to_s.strip == ''
        out << "<div>#{e.to_s}</div>"
      when Nokogiri::XML::Element
        # if the element is a page break. Add an image and a text blurb.
        next if e.name == 'br'
        if e.attr('class') == "pageheader"
          out << "</div><!-- /col-md-6 -->\n</div><!-- /row -->" if page > 1
          out << "<div class=\"row\" data-page=\"#{page}\">"
          page += 1
          out << "<div class=\"col-md-6\">"
          file_id = id_for_filename(e.attr('data-image'))
          out << image_tag(Riiif::Engine.routes.url_helpers.image_path(file_id, size: ',600')) if file_id
          out << "</div><div class=\"col-md-6\">"
        end
        out << e.to_s
      end
    end
    out << "</div><!-- /col-md-6 -->\n</div><!-- /row -->\n" if page > 1
    out << "</div><!-- /tei-content -->\n"
    out.html_safe
  end

  def id_for_filename(filename)
    result = Worthwhile::GenericFile.where(is_part_of_ssim: self.internal_uri, desc_metadata__title_sim: filename).first
    result && result.id
  end
end
