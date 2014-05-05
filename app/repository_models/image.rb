# Generated via
#  `rails generate curate:work Text`
require 'active_fedora/base'
class Image < ActiveFedora::Base
  include CurationConcern::Work
  include CurationConcern::WithGenericFiles
  include CurationConcern::WithLinkedResources
  include CurationConcern::WithLinkedContributors
  include CurationConcern::WithRelatedWorks
  include CurationConcern::Embargoable
  include ActiveFedora::RegisteredAttributes
  include CurationConcern::WithDatastreamAttachments
  
  self.accept_datastream_attachments ["VRA", "MODS"]
  
  include CurationConcern::WithCaseBasicMetadata
  has_metadata "descMetadata", type: GenericWorkRdfDatastream

  include CurationConcern::RemotelyIdentifiedByDoi::Attributes
  
  class_attribute :human_readable_short_description
  self.human_readable_short_description = "Any Image work, preferably with VRA xml attached."

  attribute :files, multiple: true, form: {as: :file},
    hint: "CTRL-Click (Windows) or CMD-Click (Mac) to select multiple files."

end
