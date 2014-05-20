module CurationConcern::CaseWork
  extend ActiveSupport::Concern

  included do
    include CurationConcern::WithDatastreamAttachments
    include CurationConcern::WithCaseBasicMetadata
  end

  # override sufia
  def to_param
    pid
  end
end
