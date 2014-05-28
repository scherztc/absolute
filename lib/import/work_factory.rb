require 'import/dc_parser'

class WorkFactory

  # Used by the ObjectImporter to select the right class for
  # importing a fedora object.

  def initialize(source_object)
    @source_object = source_object
  end

  # Initialize a new work with attributes from the source
  # object's DC datastream.  The type of work that will be
  # returned will be decided by examining the source_object.
  def build_work
    dc_attrs = DcParser.from_xml(@source_object.datastreams['DC'].content).to_attrs_hash
    work_class.new(dc_attrs)
  end

  def work_class
    if video?
      return Video
    elsif audio?
      return Audio
    elsif has_tei?
      return Text
    elsif image?
      return Image
    elsif has_pdf?
      return Text
    else
      return CaseGenericWork
    end
  end

  def mime_types
    return @mime_types if @mime_types
    @mime_types = []
    @source_object.datastreams.keys.each do |dsid|
      @mime_types << @source_object.datastreams[dsid].mimeType
    end
    @mime_types = @mime_types.compact.uniq
  end

  def video?
    video_types = ['video/mpeg', 'video/mp4']
    mime_types.any?{|mime_type| video_types.include?(mime_type) }
  end

  def audio?
    audio_types = ['audio/x-wav', 'audio/mpeg']
    mime_types.any?{|mime_type| audio_types.include?(mime_type) }
  end

  def has_tei?
    tei_dsids = ['tei', 'teip5', 'tei.xml', 'teip5.xml']
    @source_object.datastreams.keys.any? { |dsid|
      tei_dsids.include?(dsid.downcase)
    }
  end

  def image?
    image_extensions = ['tif', 'gif', 'jp2', 'jpg']
    @source_object.datastreams.keys.any?{ |dsid|
      file_extension = dsid.match(/^.*\.(.*)$/)
      file_extension = file_extension[1] if file_extension
      file_extension = file_extension.downcase if file_extension
      image_extensions.include?(file_extension)
    }
  end

  def has_pdf?
    pdf_types = ['application/pdf']
    mime_types.any?{|mime_type| pdf_types.include?(mime_type) }
  end

end
