# Generated via
#  `rails generate curate:work Text`
require 'active_fedora/base'
class CaseGenericWork < ActiveFedora::Base
  include CurationConcern::Work
  include CurationConcern::CaseWork
  
  self.human_readable_short_description = "Any type of work, with files associated and XML optionally attached."
  self.accept_datastream_attachments ["MODS", "TEI", "TEIP5","VRA", "PBCore", "METS"]
  
  validates_presence_of :rights, message: 'You must select a license for your work.'

  has_metadata "descMetadata", type: GenericWorkRdfDatastream
end
