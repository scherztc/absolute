class BulkUpdateController < ApplicationController
  include Worthwhile::ThemedLayoutController
  include ApplicationHelper
  with_themed_layout '1_column'

  authorize_resource class: false

  def update
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

  # This method updates each instance of the specified :old language with the :new language
  def replace_language
    get_pids("desc_metadata__language_sim:\"#{params[:old]}\"").each do |pid|
      item = ActiveFedora::Base.find( pid['id'] )
      if item['language'].include?( params[:old] )
        item['language'] << params[:new]
        item['language'] -= [params[:old]]
        item.save
        item.update_index
      end
    end

    redirect_to '/bulk_update/'
  end

  # This replaces a value it the people facet
  def replace_person
    get_pids("desc_metadata__creator_sim:\"#{params[:old]}\"").each do |pid|
      item = ActiveFedora::Base.find( pid['id'] )
      if item['creator'].include?( params[:old] )
        item['creator'] << params[:new]
        item['creator'] -= [params[:old]]
        item.save
        item.update_index
      end
    end

    redirect_to '/bulk_update/'
  end

end
