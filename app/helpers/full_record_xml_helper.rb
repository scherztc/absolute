module FullRecordXmlHelper

  # Renders a modal div with the contents of the MODS datastream if there is a MODS datastream present
  def render_full_record(curation_concern)
    ds =  curation_concern.datastreams["MODS"]
    unless ds.nil? || ds.empty?
      content_tag :div, {class:"modal fade", id:"fullRecord", tabindex:"-1", role:"dialog", "aria-labelledby"=>"myModalLabel", "aria-hidden"=>"true" } do
        content_tag :div, class:"modal-dialog" do
          content_tag :div, class:"modal-content" do
            head = content_tag :div, "MODS Record detected.  Listing contents:", class:"modal-header"
            body = content_tag :div, class:"modal-body" do
              pretty_xml(ds.content)
            end
            head+body
          end
        end
      end
    end
  end

  # Renders a link to display the "full record" if there is a MODS datastream present
  def full_record_link(curation_concern)
    ds =  curation_concern.datastreams["MODS"]
    unless ds.nil? || ds.empty?
      link_to "Show MODS Metadata", "#", "data-toggle"=>"modal", "data-target"=>"#fullRecord"
    end
  end

  # Renders an xml document as HTML <ul> list
  # This is tuned to render MODS records starting from /modsCollection/mods as the root of the content that's rendered.
  def pretty_xml(xml)
    ng_xml = Nokogiri::XML(xml,&:noblanks)
    tag = content_tag :ul, class:"pretty-xml", id:"fullRecord" do
      ng_xml.root.children.first.children.collect {|node| concat(pretty_node(node))}
    end
    tag
  end

  # Renders an xml node as an HTML <li> element
  def pretty_node(node)
    tag = content_tag :li do
      if node.name == "text"
        inner = ""
      else
        inner = "<label>#{node.name.underscore.humanize}</label>".html_safe
      end
      if node.children.empty?
        inner << node.text
      elsif node.children.count == 1
        inner << node.children.first.text
      end
      inner
    end
    if node.children.count > 1
      inner = content_tag :ul do
        node.children.collect {|node| concat(pretty_node(node))}
      end
      tag << inner
    end

    tag
  end
end
