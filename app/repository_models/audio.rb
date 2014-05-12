# Generated via
#  `rails generate curate:work Audio`
require 'active_fedora/base'
class Audio < ActiveFedora::Base
  include CurationConcern::Work
  include CurationConcern::CaseWork
    
  self.human_readable_short_description = "Any Audio work, possibly with PBCore xml attached."
  self.accept_datastream_attachments ["PBCore", "MODS"]
  
  validates_presence_of :rights, message: 'You must select a license for your work.'

  has_metadata "descMetadata", type: GenericWorkRdfDatastream
end
