require 'spec_helper'

describe CurationConcern::GenericFilesController do
  let(:user) { FactoryGirl.create(:user) }
  let(:visibility) { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE }
  let(:parent) {
    FactoryGirl.create_curation_concern(:case_generic_work, user, {visibility: visibility})
  }
  describe "#create" do
    it "should create and save a file asset from the given params" do
      @file_count = GenericFile.count
      sign_in user
      date_today = Date.today
      Date.stub(:today).and_return(date_today)
      file = fixture_file_upload('files/anoabo00.pdf','image/png')
      xhr :post, :create, :files=>[file], :Filename=>"anoabo00.pdf", :parent_id => parent.to_param, :permission=>{"group"=>{"public"=>"read"} }, :terms_of_service => '1'
      
      expect(response).to(
        redirect_to(controller.polymorphic_path([:curation_concern, parent]))
      )
      
      GenericFile.count.should == @file_count + 1

      saved_file = parent.generic_files.first

      # This is confirming that the correct file was attached
      saved_file.label.should == 'anoabo00.pdf'

      # Confirming that date_uploaded and date_modified were set
      saved_file.date_uploaded.should == date_today
      saved_file.date_modified.should == date_today
    end
    
    it "should support multifile json upload" do
      @file_count = GenericFile.count
      sign_in user
      date_today = Date.today
      Date.stub(:today).and_return(date_today)
      file = fixture_file_upload('files/anoabo00.pdf','image/png')
      xhr :post, :create, :files=>[file], :Filename=>"anoabo00.pdf", :parent_id => parent.to_param, :permission=>{"group"=>{"public"=>"read"} }, :terms_of_service => '1', :format=>:json
      
      response.should be_successful
      GenericFile.count.should == @file_count + 1

      saved_file = parent.generic_files.first
      
      JSON.parse(response.body).should == [{"name"=>["anoabo00.pdf"], "size"=>[""], "url"=>curation_concern_generic_file_path(saved_file), "thumbnail_url"=>saved_file.pid, "delete_url"=>"deleteme", "delete_type"=>"DELETE"}]
      
      

      # This is confirming that the correct file was attached
      saved_file.label.should == 'anoabo00.pdf'

      # Confirming that date_uploaded and date_modified were set
      saved_file.date_uploaded.should == date_today
      saved_file.date_modified.should == date_today
    end
  end
end