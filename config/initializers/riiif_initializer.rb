Riiif::Image.file_resolver = Riiif::HTTPFileResolver
Riiif::Image.info_service = lambda do |id, file|
  resp = get_solr_response_for_doc_id id
  doc = resp.first['response']['docs'].first
  { height: doc['height_isi'], width: doc['width_isi'] }
end
include Blacklight::SolrHelper
def blacklight_config
  CatalogController.blacklight_config
end

Riiif::HTTPFileResolver.id_to_uri = lambda do |id| 
  pid = Sufia::Noid.namespaceize(id)
  connection = ActiveFedora::Base.connection_for_pid(pid)
  host = connection.config[:url]
  path = connection.api.datastream_content_url(pid, 'content', {})
  host + '/' + path
end


Riiif::Engine.config.cache_duration_in_days = 30
