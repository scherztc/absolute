class Collection < ActiveFedora::Base
  include Hydra::Collection
  include CurationConcern::CollectionModel
  include Hydra::Collections::Collectible

  include CurationConcern::WithCaseBasicMetadata
  has_metadata "descMetadata", type: GenericWorkRdfDatastream
  
  def can_be_member_of_collection?(collection)
    collection == self ? false : true
  end

  def to_solr(solr_doc={}, opts={})
    super(solr_doc, opts)
    index_collection_pids(solr_doc)
    return solr_doc
  end
end
