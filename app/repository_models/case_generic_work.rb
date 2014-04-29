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
  
  has_metadata "descMetadata", type: GenericWorkRdfDatastream
  # has_file_datastream "TEI", type: FileContentDatastream
  # attribute :TEI, multiple: false, form: {as: :file}
  # has_file_datastream "TEIP5", type: FileContentDatastream
  # attribute :TEIP5, multiple: false, form: {as: :file}
  # has_file_datastream "MODS", type: FileContentDatastream
  # attribute :MODS, multiple: false, form: {as: :file}
  
  self.accept_datastream_attachments ["TEI", "TEIP5", "MODS"]
  
  # 
  # self.accepted_attachments.each do |attachment_dsid|
  #   has_file_datastream attachment_dsid, type: FileContentDatastream
  #   attribute attachment_dsid.to_sym, multiple: false, form: {as: :file}
  # end
  # 
  # def attachments 
  #   datastreams.select {|dsid, ds| self.class.accepted_attachments.include?(dsid.to_sym) }
  # end

  include CurationConcern::RemotelyIdentifiedByDoi::Attributes
  
  class_attribute :human_readable_short_description
  self.human_readable_short_description = "Any type of work, with files associated and XML optionally attached."
  
  attribute :title, datastream: :descMetadata,
    multiple: false,
    validates: {presence: { message: 'Your work must have a title.' }}

  attribute :rights, datastream: :descMetadata,
    multiple: false,
    validates: {presence: { message: 'You must select a license for your work.' }}

  attribute :created,        datastream: :descMetadata, multiple: false
  attribute :description,    datastream: :descMetadata, multiple: false
  attribute :date_uploaded,  datastream: :descMetadata, multiple: false
  attribute :date_modified,  datastream: :descMetadata, multiple: false
  attribute :available,      datastream: :descMetadata, multiple: false
  attribute :creator,        datastream: :descMetadata, multiple: false
  attribute :content_format, datastream: :descMetadata, multiple: false
  attribute :identifier,     datastream: :descMetadata, multiple: false

  attribute :contributor,            datastream: :descMetadata, multiple: true
  attribute :publisher,              datastream: :descMetadata, multiple: true
  attribute :bibliographic_citation, datastream: :descMetadata, multiple: true
  attribute :source,                 datastream: :descMetadata, multiple: true
  attribute :language,               datastream: :descMetadata, multiple: true
  attribute :extent,                 datastream: :descMetadata, multiple: true
  attribute :requires,               datastream: :descMetadata, multiple: true
  attribute :subject,                datastream: :descMetadata, multiple: true

  attribute :files, multiple: true, form: {as: :file},
    hint: "CTRL-Click (Windows) or CMD-Click (Mac) to select multiple files."
  

end
