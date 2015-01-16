class BulkUpdateController < ApplicationController
  include Worthwhile::ThemedLayoutController
  with_themed_layout '1_column'

  def update
  end

  def replace_subject
    solr = RSolr.connect( url: "http://localhost:8983/solr/" )
    response = solr.get( 'select', params: {q: "desc_metadata__subject_tesim:#{params[:old]}", fl: "id", } )
    pids = response['response']['docs']

    pids.each do |pid|
      item = ActiveFedora::Base.find(pid['id'])
      item['subject'] << "#{params[:new]}"
      item['subject'] -= ["#{params[:old]}"]
      item.save
      item.update_index
    end

    render action: "index"
  end

end
