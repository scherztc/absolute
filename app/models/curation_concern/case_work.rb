module CurationConcern::CaseWork
  extend ActiveSupport::Concern
  include CurationConcern::Work
  include CurationConcern::WithDatastreamAttachments
  include CurationConcern::WithBasicMetadata
  include CurationConcern::WithLicense
  include RegistersHandles

  # override sufia
  def to_param
    pid
  end

end
