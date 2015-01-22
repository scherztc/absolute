class BulkUpdateController < ApplicationController
  include Worthwhile::ThemedLayoutController
  with_themed_layout '1_column'

  authorize_resource class: false

  def update
  end

  # Create a connection to the local solr server
  def remote_solr
    return @remote_solr if @remote_solr
    solr_config_file = Rails.root.join('config', 'solr.yml')
    config_erb = ERB.new(IO.read(solr_config_file)).result(binding)
    location = Psych.load(config_erb)[Rails.env]
    @remote_solr = RSolr.connect( url: location['url'] )
  end

  # Get the PIDs for a specified search
  def get_pids(query)
    response = remote_solr.get('select', params: { q: query, fl: "id", rows: 1000 } )
    pids = response['response']['docs']
  end

  # This replaces each instance of the :old value with the :new value
  def replace_subject
    get_pids("desc_metadata__subject_sim:\"#{params[:old]}\"").each do |pid|
      item = ActiveFedora::Base.find(pid['id'])
      if item['subject'].include?(params[:old])
        item['subject'] << params[:new]
        item['subject'] -= [params[:old]]
        item.save
        item.update_index
      end
    end

    redirect_to '/bulk_update/'
  end

  # This method takes a string and splits it on a specified character
  def split_subject
    get_pids("desc_metadata__subject_sim:\"#{params[:string]}\"").each do |pid|
      item = ActiveFedora::Base.find( pid['id'] )
      if item['subject'].include?( params[:string] )
        fields = params[:string].split(params[:character])
        fields.each do |field|
          item['subject'] << field.strip
        end
        item['subject'] -= [params[:string]]
        item.save
        item.update_index
      end
    end

    redirect_to '/bulk_update/'
  end

end
