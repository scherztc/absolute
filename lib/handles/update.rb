module Handles
  class Update
    include ApplicationHelper

    @@batch_size = 10
    @@query = "desc_metadata__identifier_tesim:*"

    def get_batch(start)
      fields = "id desc_metadata__identifier_tesim"
      remote_solr.get('select', params: {q: @@query, fl: fields, start: start, rows: @@batch_size})
    end

    # fund the total number of items that will be updated
    def get_total
      return @total if @total
      @total = remote_solr.get('select', params: {q: @@query, fl: "id", rows: 10})['response']['numFound']
    end

    def pid_to_handle(item, pid=nil)
      pid = item['id'] if pid.nil?
      work = ActiveFedora::Base.find(item['id'])
      identifier = "http://hdl.handle.net/2186/#{pid}"
      work.identifier -= [pid]
      work.identifier << identifier
      work.save
      work.update_index
      return identifier
    end

    def verify_handle(item)
      item['desc_metadata__identifier_tesim'].each do |identifier|
        if identifier[0..26] == "http://hdl.handle.net/2186/"
          puts "    Item #{item['id']}: #{item['desc_metadata__identifier_tesim']}"
        elsif identifier[0..3] == 'ksl:'
          handle = pid_to_handle(item, identifier)
          puts "    * Item #{item['id']}: #{identifier} updated to #{handle}"
        elsif identifier[0..6] == "urn:doi" or idnetifier[0..2] == "DOI"
          puts "    Item #{item['id']}: #{identifier} is DOI"
        else
          puts "    ERROR: unknown value \"#{identifier}\" for #{item['id']}"
        end
      end
    end

    def update!
      start = 0

      while start < get_total do
        puts "Getting IDs #{start}..#{start + @@batch_size} of #{get_total}"
        get_batch(start)['response']['docs'].each do |item|
          verify_handle(item)
        end
        start += @@batch_size
      end
    end

  end
end
