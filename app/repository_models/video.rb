# Generated via
#  `rails generate curate:work Video`
require 'active_fedora/base'
class Video < ActiveFedora::Base
  include CurationConcern::Work
  include CurationConcern::CaseWork

  self.human_readable_short_description = "Any Video work, preferably with PBCore xml attached."
  self.accept_datastream_attachments ["PBCore", "MODS"]
  
  validates_presence_of :rights, message: 'You must select a license for your work.'

  has_metadata "descMetadata", type: GenericWorkRdfDatastream
end
