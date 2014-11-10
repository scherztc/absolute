module CurationConcern::WithBasicMetadata
  extend ActiveSupport::Concern

  included do
    has_metadata "descMetadata", type: ::GenericWorkMetadata

    validates_presence_of :title, message: 'Your work must have a title'

    has_attributes :created, :date_modified, :date_uploaded, datastream: :descMetadata, multiple: false
    has_attributes :contributor, :creator, :coverage, :date, :description, :content_format, :identifier,
      :language, :publisher, :relation, :rights, :source, :subject, :title, :type, :extent,
      datastream: :descMetadata, multiple: true
  end

end
