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
    # Validations that apply to all types of Work AND Collections
    # Any other validations (ie. presence of dc:rights info) should be declared on the specific Work models.
    validates_presence_of :title, message: 'Your work must have a title.' 
      
    # Single-value fields
    has_attributes :available,:created,:content_format,:date_modified,
                   :date_uploaded,:description,:rights,:title,
                datastream: :descMetadata, multiple: false
                
    # Multi-value fields
    has_attributes :contributor, :creator, :contributors,:coverage,:date,:extent,:identifier,:language,
                   :publisher,:relation,:requires,:rights,:source,:subject,:type,
                datastream: :descMetadata, multiple: true
  end
  
end