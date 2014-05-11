module ThumbnailHelper
  
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
  
  def generic_file_thumbnail_tag(generic_file, width=36)
    if generic_file.image? || generic_file.pdf? 
      path = download_path(generic_file, {datastream_id: 'thumbnail'})
    elsif generic_file.audio? 
      path = "Audio.png"
    elsif generic_file.video? 
      path = "Video.png"
    else
      path = "Other.png" 
    end
    image_tag(path, width: width, class: 'thumbnail')   
  end  
  
  def generic_file_thumbnail_link_tag(generic_file, width=36)
    link_to generic_file_thumbnail_tag(generic_file, width), curation_concern_generic_file_path(generic_file.noid), class: 'canonical-image'    
  end
  
end
