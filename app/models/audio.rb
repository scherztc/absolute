class Audio < ActiveFedora::Base
  include CurationConcern::CaseWork

  self.human_readable_short_description = "Any Audio work, possibly with PBCore xml attached."
  self.accept_datastream_attachments ["PBCore","MODS","QDC"]
end
