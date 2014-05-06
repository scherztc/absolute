module ApplicationHelper
  
  # @parameter document SolrDocument that you want to display a thumbnail for
  def document_thumbnail_tag(document, width=36)
    if document.respond_to?(:representative_image_url) && document.representative_image_url.present? 
      path = document.representative_image_url 
    else 
      case document
      when Image
        path = "Image.png"
      when Text
        path = "Text.png"
      when Audio
        path = "Audio.png"
      when Video
        path = "Video.png" 
      else
        path = "Other.png" 
      end
    end 
    image_tag(path, {width: width, class: "canonical-image"}) 
  end
  
end
