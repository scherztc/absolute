Riiif::Image.file_resolver = Riiif::HTTPFileResolver

Riiif::HTTPFileResolver.id_to_uri = lambda do |id| 
  pid = Sufia::Noid.namespaceize(id)
  connection = ActiveFedora::Base.connection_for_pid(pid)
  host = connection.config[:url]
  path = connection.api.datastream_content_url(pid, 'content', {})
  host + '/' + path
end

