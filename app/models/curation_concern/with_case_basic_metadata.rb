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
    has_metadata "descMetadata", type: GenericWorkRdfDatastream
    # Validations that apply to all types of Work AND Collections
    validates_presence_of :title,  message: 'Your work must have a title.' 

      
    # Single-value fields
    has_attributes :created, :date_modified, :date_uploaded, :description, :rights, :title,
                datastream: :descMetadata, multiple: false
                
    # Multi-value fields
    has_attributes :contributor, :creator, :coverage, :date, :content_format, :identifier, :language,
                   :publisher, :relation, :rights, :source, :subject, :type,
                datastream: :descMetadata, multiple: true
  end
  
end
