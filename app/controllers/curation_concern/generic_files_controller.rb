class CurationConcern::GenericFilesController < CurationConcern::BaseController
  include Curate::ParentContainer

  respond_to(:html)

  def attach_action_breadcrumb
    add_breadcrumb "#{parent.human_readable_type}", polymorphic_path([:curation_concern, parent])
    super
  end

  before_filter :parent
  before_filter :authorize_edit_parent_rights!, except: [:show]

  self.excluded_actions_for_curation_concern_authorization = [:new, :create]
  def action_name_for_authorization
    (action_name == 'versions' || action_name == 'rollback') ? :edit : super
  end
  protected :action_name_for_authorization

  self.curation_concern_type = GenericFile

  def new
    curation_concern.copy_permissions_from(parent)
    respond_with(curation_concern)
  end

  def create    
    curation_concern.batch = parent
    if actor.create
      respond_with([:curation_concern, parent]) {|wants|
        wants.json {
          render :json => [generic_file_to_json(curation_concern)]
        }
      }
    else
      respond_with([:curation_concern, curation_concern]) { |wants|
        wants.html { render 'new', status: :unprocessable_entity }
      }
    end
  end


  def show
    respond_with(curation_concern)
  end

  def edit
    respond_with(curation_concern)
  end

  def update
    if actor.update
      respond_with([:curation_concern, curation_concern])
    else
      respond_with([:curation_concern, curation_concern]) { |wants|
        wants.html { render 'edit', status: :unprocessable_entity }
      }
    end
  end

  def versions
    respond_with(curation_concern)
  end

  def rollback
    if actor.rollback
      respond_with([:curation_concern, curation_concern])
    else
      respond_with([:curation_concern, curation_concern]) { |wants|
        wants.html { render 'versions', status: :unprocessable_entity }
      }
    end
  end

  def destroy
    parent = curation_concern.batch
    flash[:notice] = "Deleted #{curation_concern}"
    curation_concern.destroy
    respond_with([:curation_concern, parent])
  end
  
  def attributes_for_actor
    if params[:files]
      return {title:params[:Filename], file:params[:files].first}
    elsif cloud_resources_to_ingest.nil?
      return params[hash_key_for_curation_concern] 
    else
      return params[hash_key_for_curation_concern].merge!(:cloud_resources=>cloud_resources_to_ingest)
    end
  end

  register :actor do
    CurationConcern.actor(curation_concern, current_user, attributes_for_actor)
  end
  
  protected
  
  def json_error(error, name=nil, additional_arguments={})
    args = {:error => error}
    args[:name] = name if name
    render additional_arguments.merge({:json => [args]})
  end
  
  def generic_file_to_json(generic_file)
    return {
      "name" => generic_file.title,
      "size" => generic_file.file_size,
      "url" => "/concern/generic_files/#{generic_file.noid}",
      "thumbnail_url" => generic_file.pid,
      "delete_url" => "deleteme", # generic_file_path(:id => id),
      "delete_type" => "DELETE"
    }
  end

end
