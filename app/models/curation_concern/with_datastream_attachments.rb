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

  def to_solr(solr_doc={})
    super.tap do |solr_doc|
      solr_doc[Solrizer.solr_name('datastreams', :symbol)] = attachment_datastreams
    end
  end

  private

    def attachment_datastreams
      datastreams.except('RELS-EXT', 'DC', 'properties', 'rightsMetadata', 'descMetadata').select { |key, value| value.has_content? }.keys
    end
end
