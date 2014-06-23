require 'import/dc_parser'
require 'import/legacy_object'
require 'import/rels_ext_parser'

class PidAlreadyInUseError < StandardError; end

class ObjectFactory

  # Used by the ObjectImporter to select the right class for
  # importing a fedora object.

  # This code relies on assumptions about how the fedora data
  # looks in Digital Case 1.0 (the source fedora that we will
  # import objects from).
  # For example, in Digital Case 1.0 there are some objects
  # with a datastream that has a dsid called "VIDEO" and has
  # a controlGroup of "R" or "E".  When we import that object,
  # we are assuming that the object's class should be Video
  # and that the dsLocation of the "VIDEO" datastream should
  # become the url for a LinkedResource that is associated with
  # that new Video object.

  def initialize(source_object)
    @source_object = source_object
  end

  # Initialize a new object with attributes from the source
  # object's DC datastream.  The type of work that will be
  # returned will be decided by examining the @source_object.
  def build_object
    validate_datastreams!
    attrs = DcParser.from_xml(@source_object.datastreams['DC'].content).to_h
    obj = LegacyObject.new(attrs)
    obj.pid = set_pid
    obj.visibility = visibility
    return object_class, obj
  end

  def visibility
    Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
  end

  def validate_datastreams!
    datastreams = @source_object.datastreams
    uniq_datastreams = datastreams.keys.map(&:upcase).map { |f| f.sub(/\.XML/, '')}.uniq
    raise "Datastreams are not unique for #{@source_object.pid}" unless uniq_datastreams.size == datastreams.size
  end

  def set_pid
    if ActiveFedora::Base.exists?(@source_object.pid)
      raise PidAlreadyInUseError.new
    end
    @source_object.pid
  end

  def object_class
    if collection?
      Collection
    elsif video?
      Video
    elsif audio?
      Audio
    elsif has_tei?
      Text
    elsif image?
      Image
    elsif has_pdf?
      Text
    elsif has_external_video_link?
      Video
    elsif has_external_article_link?
      Text
    else
      Text
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

  def member_ids
    return @member_ids if @member_ids
    @member_ids = []
    if @source_object.datastreams['RELS-EXT']
      rels = @source_object.datastreams['RELS-EXT'].content
      @member_ids = RelsExtParser.new(rels).collection_member_ids
    end
  end

  def collection?
    !member_ids.empty?
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

  def has_external_video_link?
    dsids_for_videos = ['video']
    has_external_link_for?(dsids_for_videos)
  end

  def has_external_article_link?
    dsids_for_texts = ['article']
    has_external_link_for?(dsids_for_texts)
  end

  def has_external_link_for?(special_dsids)
    @source_object.datastreams.keys.any?{ |dsid|
      has_matching_dsid = special_dsids.map(&:downcase).include?(dsid.downcase)
      ds = @source_object.datastreams[dsid]
      has_matching_dsid && (ds.external? || ds.redirect?)
    }
  end

end
