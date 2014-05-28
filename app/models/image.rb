class Image < ActiveFedora::Base
  include CurationConcern::CaseWork
  
  self.human_readable_short_description = "Any Image work, preferably with VRA xml attached."
  self.accept_datastream_attachments ["VRA", "MODS", "QDC"]
  
  validates_presence_of :rights, message: 'You must select a license for your work.'

  has_metadata "descMetadata", type: GenericWorkRdfDatastream
end
