module ThumbnailHelper
  
  # @parameter document SolrDocument that you want to display a thumbnail for
  def thumbnail_tag(document, image_options)
    if document.representative.present?
      super
    else 
      path = case document.hydra_model
      when 'Image', 'Text', 'Audio', 'Video'
        "#{document.hydra_model}.png"
      else
        "Other.png" 
      end
      image_tag path, class: "canonical-image"
    end 
  end
  
  def generic_file_thumbnail_tag(generic_file, width=36)
    path = if generic_file.image? || generic_file.pdf? 
      download_path(generic_file, {datastream_id: 'thumbnail'})
    elsif generic_file.audio? 
      "Audio.png"
    elsif generic_file.video? 
      "Video.png"
    else
      "Other.png" 
    end
    image_tag(path, width: width, class: 'thumbnail')   
  end  
  
  def generic_file_thumbnail_link_tag(generic_file, width=36)
    link_to generic_file_thumbnail_tag(generic_file, width), curation_concern_generic_file_path(generic_file.noid), class: 'canonical-image'    
  end
  
end
