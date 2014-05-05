# Generated via
#  `rails generate curate:work Video`
require 'active_fedora/base'
require Rails.root.join('app/repository_datastreams/video_rdf_datastream')
class Video < ActiveFedora::Base
  include CurationConcern::Work
  include CurationConcern::WithGenericFiles
  include CurationConcern::WithLinkedResources
  include CurationConcern::WithLinkedContributors
  include CurationConcern::WithRelatedWorks
  include CurationConcern::Embargoable
  include ActiveFedora::RegisteredAttributes
  include CurationConcern::WithCaseBasicMetadata
  has_metadata "descMetadata", type: GenericWorkRdfDatastream
  
  include CurationConcern::WithDatastreamAttachments
  self.accept_datastream_attachments ["PBCore", "MODS"]

  include CurationConcern::RemotelyIdentifiedByDoi::Attributes
  
  class_attribute :human_readable_short_description
  self.human_readable_short_description = "Any Video work, preferably with PBCore xml attached."

  attribute :files, multiple: true, form: {as: :file},
    hint: "CTRL-Click (Windows) or CMD-Click (Mac) to select multiple files."

end
