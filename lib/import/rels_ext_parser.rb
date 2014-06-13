class RelsExtParser

  REL_NS = 'info:fedora/fedora-system:def/relations-external#'
  RDF_NS = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#'

  attr_accessor :doc

  def initialize(rdf_xml)
    @doc = Nokogiri::XML.parse(rdf_xml)
  end

  def collection_member_ids
    rdf_ns = doc.namespaces.key(RDF_NS)
    rel_ns = doc.namespaces.key(REL_NS)
    return [] unless rdf_ns && rel_ns

    rdf_prefix = rdf_ns.match(/xmlns:(.*)/)[1]
    rel_prefix = rel_ns.match(/xmlns:(.*)/)[1]
    uris = doc.xpath("//#{rdf_prefix}:Description/#{rel_prefix}:hasCollectionMember/@#{rdf_prefix}:resource").map(&:text)
    pids = uris.map { |uri| uri.sub('info:fedora/', '') }
  end

end
