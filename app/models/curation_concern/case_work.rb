module CurationConcern::CaseWork
  extend ActiveSupport::Concern
  include CurationConcern::Work
  include CurationConcern::WithDatastreamAttachments
  include CurationConcern::WithCaseBasicMetadata
  include CurationConcern::WithLicense

  # override sufia
  def to_param
    pid
  end

end
