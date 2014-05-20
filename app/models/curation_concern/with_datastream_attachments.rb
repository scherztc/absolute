module CurationConcern::WithDatastreamAttachments
  extend ActiveSupport::Concern

  included do
    class_attribute :accepted_attachments
    self.accepted_attachments = []
    
    # Register datastreams to accept attachments on
    # @example
    #   class Text < ActiveFedora::Base
    #     include CurationConcern::WithDatastreamAttachments
    #     self.accept_datastream_attachments ["TEI", "MODS"]
    #   end
    def self.accept_datastream_attachments(attachment_dsids)
      attachment_dsids.each do |attachment_dsid|
        self.accepted_attachments << attachment_dsid
        has_file_datastream attachment_dsid, type: FileContentDatastream
        attr_accessor attachment_dsid.to_sym
      end
    end
  end
  
  def attachments 
    datastreams.select {|dsid, ds| self.class.accepted_attachments.include?(dsid) }
  end
  
end