class BulkUpdateController < ApplicationController
  include Worthwhile::ThemedLayoutController
  include ApplicationHelper
  with_themed_layout '1_column'

  authorize_resource class: false

  def update
  end

  # Get the PIDs for a specified search
  def get_pids(query)
    response = remote_solr.get('select', params: { q: query, fl: "id", rows: 100000 } )
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
        item[params[:field]] << params[:string].split(params[:char]).collect(&:strip)
        item[params[:field]] -= [params[:string]]
        item.save
        item.update_index
      end
    end
    redirect_to bulk_update_path
  end

  # This function updates each identifier that is not a doi or a handle to be a handle.net link
  def update_identifier
    get_pids("desc_metadata__identifier_tesim:* -active_fedora_model_ssi:Worthwhile*").each do |pid|
      item = ActiveFedora::Base.find(pid['id'])
      ids = []
      item.identifier.each do |identifier|
        if identifier[0..20] == 'http://hdl.handle.net'
          ids << identifier
        end

        if identifier[0..3] == 'ksl:'
          ids << "http://hdl.handle.net/2186/#{identifier}"
        end
        
        if identifier[0..2] == "DOI"
          ids << identifier
        end
      end
      item.identifier = ids unless ids.nil? or ids.empty?
      item.save unless ids.nil? or ids.empty?
      item.update_index unless ids.nil? or ids.empty?
    end 
    redirect_to bulk_update_path
  end

end
