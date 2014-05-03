# Basic metadata for all Case Works
# Required fields: 
#   dc:title
#   dc:rights
#
# Optional fields:
#   dc:contributor
#   dc:coverage
#   dc:creator
#   dc:date
#   dc:description
#   dc:format
#   dc:identifier
#   dc:language
#   dc:publisher
#   dc:relation
#   dc:source
#   dc:subject
#   dc:type
module CurationConcern::WithCaseBasicMetadata
  extend ActiveSupport::Concern

  included do
    attribute :title, datastream: :descMetadata,
      multiple: false,
      validates: {presence: { message: 'Your work must have a title.' }}

    attribute :rights, datastream: :descMetadata,
      multiple: false,
      validates: {presence: { message: 'You must select a license for your work.' }}
      
    attribute :available,      datastream: :descMetadata, multiple: false
    attribute :created,        datastream: :descMetadata, multiple: false
    attribute :creator,        datastream: :descMetadata, multiple: false
    attribute :content_format, datastream: :descMetadata, multiple: false
    attribute :date_modified,  datastream: :descMetadata, multiple: false
    attribute :date_uploaded,  datastream: :descMetadata, multiple: false
    attribute :description,    datastream: :descMetadata, multiple: false

    attribute :bibliographic_citation,  datastream: :descMetadata, multiple: true
    attribute :contributor,             datastream: :descMetadata, multiple: true
    attribute :coverage,                datastream: :descMetadata, multiple: true
    attribute :date,                    datastream: :descMetadata, multiple: true
    attribute :extent,                  datastream: :descMetadata, multiple: true
    attribute :format,                  datastream: :descMetadata, multiple: true
    attribute :identifiers,             datastream: :descMetadata, multiple: true
    attribute :language,                datastream: :descMetadata, multiple: true
    attribute :publisher,               datastream: :descMetadata, multiple: true
    attribute :relation,                datastream: :descMetadata, multiple: true
    attribute :requires,                datastream: :descMetadata, multiple: true
    attribute :rights,                  datastream: :descMetadata, multiple: true
    attribute :source,                  datastream: :descMetadata, multiple: true
    attribute :subject,                 datastream: :descMetadata, multiple: true
    attribute :type,                    datastream: :descMetadata, multiple: true
  end
  
end