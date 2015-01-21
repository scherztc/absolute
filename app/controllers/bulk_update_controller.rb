class BulkUpdateController < ApplicationController
  include Worthwhile::ThemedLayoutController
  with_themed_layout '1_column'

  def update
  end

  # Create a connection to the local solr server
  def remote_solr
    return @remote_solr if @remote_solr
    solr_config_file = Rails.root.join('config', 'solr.yml')
    config_erb = ERB.new(IO.read(solr_config_file)).result(binding)
    location = Psych.load(config_erb){Rails.env}
    @remote_solr = RSolr.connect( url: location['url'] )
  end

  # This replaces each instance of the :old value with the :new value
  def replace_subject
    response = remote_solr.get( 'select', params: {q: "desc_metadata__subject_tesim:#{params[:old]}", fl: "id", } )
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
