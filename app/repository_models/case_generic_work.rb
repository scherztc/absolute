# Generated via
#  `rails generate curate:work Text`
require 'active_fedora/base'
class CaseGenericWork < ActiveFedora::Base
  include CurationConcern::Work
  include CurationConcern::WithGenericFiles
  include CurationConcern::WithLinkedResources
  include CurationConcern::WithLinkedContributors
  include CurationConcern::WithRelatedWorks
  include CurationConcern::Embargoable
  include ActiveFedora::RegisteredAttributes
  include CurationConcern::WithDatastreamAttachments
  include CurationConcern::WithCaseBasicMetadata
  
  has_metadata "descMetadata", type: GenericWorkRdfDatastream
  
  self.accept_datastream_attachments ["TEI", "TEIP5", "MODS"]

  include CurationConcern::RemotelyIdentifiedByDoi::Attributes
  
  class_attribute :human_readable_short_description
  self.human_readable_short_description = "Any type of work, with files associated and XML optionally attached."

  validates_presence_of :rights, message: 'You must select a license for your work.'

  attribute :files, multiple: true, form: {as: :file},
    hint: "CTRL-Click (Windows) or CMD-Click (Mac) to select multiple files."
  

end
