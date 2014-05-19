# Generated via
#  `rails generate curate:work Text`
require 'active_fedora/base'
class Text < ActiveFedora::Base
  include CurationConcern::Work
  include CurationConcern::CaseWork
  
  self.human_readable_short_description = "Any Text work, preferably with TEI xml attached."  
  self.accept_datastream_attachments ["TEI", "TEIP5", "MODS", "METS", "QDC"]
  
  validates_presence_of :rights, message: 'You must select a license for your work.'

  has_metadata "descMetadata", type: GenericWorkRdfDatastream
end
