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

  # map the passed in values to the correct solr name
  def solr_field_name(field)
    case field
    when "subject"
      return "desc_metadata__subject_sim"
    when "creator"
      return "desc_metadata__creator_sim"
    when "language"
      return "desc_metadata__language_sim"
    end
  end

  # This funcion replaves an :old value with a :new value
  def replace
    get_pids("#{solr_field_name(params[:field])}:\"#{params[:old]}\"").each do |pid|
      item = ActiveFedora::Base.find(pid['id'])
      if item[params[:field]].include? params[:old]
        item[params[:field]] -= [params[:old]]
        item[params[:field]] << params[:new]
        item.save
        item.update_index
      end
    end
    redirect_to bulk_update_path
  end

  # This function takes a character and splits a field using that character as a delimiter
  def split
    if params[:char].nil? or params[:char].empty?
      flash[:alert] = "No delimiter entered"
      redirect_to bulk_update_path and return
    end

    get_pids("#{solr_field_name(params[:field])}:\"#{params[:string]}\"").each do |pid|
      item = ActiveFedora::Base.find(pid['id'])
      if item[params[:field]].include? params[:string]
        fields = params[:string].split(params[:char])
        fields.each do |field|
          item[params[:field]] << field.strip
        end
        item[params[:field]] -= [params[:string]]
        item.save
        item.update_index
      end
    end
    redirect_to bulk_update_path
  end

end
