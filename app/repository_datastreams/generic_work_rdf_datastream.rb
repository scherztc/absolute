class GenericWorkRdfDatastream < ActiveFedora::NtriplesRDFDatastream
  map_predicates do |map|
    map.part_of(:to => "isPartOf", :in => RDF::DC)
    # dc:title
    map.title(in: RDF::DC) do |index|
      index.as :stored_searchable
    end
    
    # dc:contributor
    map.contributor(in: RDF::DC) do |index|
      index.as :stored_searchable, :facetable
    end
    map.created(in: RDF::DC)
    # dc:creator
    map.creator(in: RDF::DC) do |index|
      index.as :stored_searchable, :facetable
    end
    # dc:description
    map.description(in: RDF::DC) do |index|
      index.type :text
      index.as :stored_searchable
    end
    # dc:subject
    map.subject(in: RDF::DC) do |index|
      index.type :text
      index.as :stored_searchable
    end

    # dc:date
    map.date(in: RDF::DC) do |index|
      index.as :stored_searchable, :sortable
    end

    map.date_uploaded(to: "dateSubmitted", in: RDF::DC) do |index|
      index.type :date
      index.as :stored_searchable, :sortable
    end
    map.date_modified(to: "modified", in: RDF::DC) do |index|
      index.type :date
      index.as :stored_searchable, :sortable
    end
    map.issued({in: RDF::DC}) do |index|
      index.as :stored_searchable
    end
    # dc:publisher
    map.publisher({in: RDF::DC}) do |index|
      index.as :stored_searchable, :facetable
    end
    map.bibliographic_citation({in: RDF::DC, to: 'bibliographicCitation'})
    # dc:rights
    map.rights(:in => RDF::DC) do |index|
      index.as :stored_searchable, :facetable
    end
    map.access_rights({in: RDF::DC, to: 'accessRights'})
    # dc:language
    map.language({in: RDF::DC}) do |index|
      index.as :searchable, :facetable
    end
    map.available({in: RDF::DC})
    # dc:coverage
    map.coverage({in: RDF::DC})
    # dc:format
    map.content_format({in: RDF::DC, to: 'format'})
    map.extent({in: RDF::DC})
    # dc:identifier
    map.identifier({in: RDF::DC})
    map.identifiers({in: RDF::DC, to: 'identifier'})
    # dc:relation
    map.type({in: RDF::DC})
    map.requires({in: RDF::DC})
    # dc:source
    map.source({in: RDF::DC})
    # dc:type
    map.type({in: RDF::DC})
    
    

    map.part(:to => "hasPart", in: RDF::DC)
  end
end

