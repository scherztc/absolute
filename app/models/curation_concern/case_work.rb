module CurationConcern::CaseWork
  extend ActiveSupport::Concern
  include CurationConcern::Work

  included do
    include CurationConcern::WithDatastreamAttachments
    include CurationConcern::WithCaseBasicMetadata
  end

  # override sufia
  def to_param
    pid
  end
end
