require 'spec_helper'

describe BulkUpdateController do
  let(:source_text) { Text.new(pid: 'ksl:test', title: ["A Test Title"], description: ["A test"], rights: [Sufia.config.cc_licenses.first]) }

  before :all do
    ActiveFedora::Base.delete_all
  end

  describe 'an admin user' do
    let(:admin) { FactoryGirl.create(:admin) }
    before { sign_in admin }

    it 'gets the update page' do
      get :index
      expect(response).to be_successful
      expect(response).to render_template(:index)
    end
  end

  describe 'a non-admin user' do 
    let(:user) { FactoryGirl.create(:user) }
    before { sign_in user }

    it 'denies access' do
      get :index
      expect(response).to redirect_to root_url
    end
  end

  describe '#replace' do
    let(:admin) { FactoryGirl.create(:admin) }

    before :each do
      sign_in admin
      source_text.subject = ["Never", "gonna", "give", "you", "up"]
      source_text.language = ['Eng']
      source_text.creator = ['Rick Astley']
      source_text.save
    end

    it 'should replace a subject with a new value' do
      post :replace, field: "subject", old: "give", new: "let"

      item = ActiveFedora::Base.find(source_text.pid)
      expect(item.subject).to eq ["Never", "gonna", "you", "up", "let"]
      expect(response).to redirect_to bulk_update_path
    end

    it 'should replace a language with a new values' do
      post :replace, field: "language", old: "Eng", new: "deu"

      item = ActiveFedora::Base.find(source_text.pid)
      expect(item.language).to eq ["deu"]
      expect(response).to redirect_to bulk_update_path
    end

    it 'should replace a creator (person facet) with a new value' do
      post :replace, field: "creator", old: "Rick Astley", new: "Astley, Rick"

      item = ActiveFedora::Base.find(source_text.pid)
      expect(item.creator).to eq ["Astley, Rick"]
      expect(response).to redirect_to bulk_update_path
    end
  end

  describe '#split' do
    let(:admin) { FactoryGirl.create(:admin) }

    before :each do
      sign_in admin
      source_text.subject = ["Never/ gonna / give/you /up"]
      source_text.language = ["eng, deu"]
      source_text.creator = ["Astley, Rick; RCA Records"]
      source_text.save
    end

    it 'should split a subject on a character' do
      post :split, field: "subject", string: "Never/ gonna / give/you /up", char: "/"

      item = ActiveFedora::Base.find(source_text.pid)
      expect(item.subject).to eq ["Never", "gonna", "give", "you", "up"]
      expect(response).to redirect_to bulk_update_path
    end

    it 'should split a language on a character' do
      post :split, field: "language", string: "eng, deu", char: ","

      item = ActiveFedora::Base.find(source_text.pid)
      expect(item.language).to eq ["eng", "deu"]
      expect(response).to redirect_to bulk_update_path
    end

    it 'should split a creator on a character' do
      post :split, field: "creator", string: "Astley, Rick; RCA Records", char: ";"

      item = ActiveFedora::Base.find(source_text.pid)
      expect(item.creator).to eq ["Astley, Rick", "RCA Records"]
      expect(response).to redirect_to bulk_update_path
    end

    it 'should prevent splitting without a character' do
      post :split, field: "subject", string: "test", char: ""

      expect(response).to redirect_to bulk_update_path
      expect(flash[:alert]).to eq "No delimiter entered"
    end
  end

  describe '#update_identifiers' do
    let(:admin) { FactoryGirl.create(:admin) }

    context 'when the identifier field is a pid' do
      before :each do
        sign_in admin
        source_text.identifier = ["ksl:test"]
        source_text.save
      end

      it 'should replace the pid with the handle link' do
        post :update_identifier

        item = ActiveFedora::Base.find(source_text.pid)
        expect(item.identifier).to eq ["http://hdl.handle.net/2186/ksl:test"]
        expect(response).to redirect_to bulk_update_path
      end
    end

    context 'when the identifier is already a handle link' do
      before :each do
        sign_in admin
        source_text.identifier = ["http://hdl.handle.net/2186/ksl:test"]
        source_text.save
      end

      it 'should not change the link' do
        post :update_identifier

        item = ActiveFedora::Base.find(source_text.pid)
        expect(item.identifier).to eq ["http://hdl.handle.net/2186/ksl:test"]
        expect(response).to redirect_to bulk_update_path
      end
    end

    context 'when there is a doi and a pid' do
      before :each do
        sign_in admin
        source_text.identifier = ["DOI: 10.1080/10408440802272158", "ksl:test"]
        source_text.save
      end

      it 'should leave the doi and update the pid to a handle' do
        post :update_identifier

        item = ActiveFedora::Base.find(source_text.pid)
        expect(item.identifier).to eq ["DOI: 10.1080/10408440802272158", "http://hdl.handle.net/2186/ksl:test"]
        expect(response).to redirect_to bulk_update_path
      end
    end

    context 'when there is a doi and a handle' do
      before :each do
        sign_in admin
        source_text.identifier = ["DOI: 10.1080/10408440802272158", "http://hdl.handle.net/2186/ksl:test"]
        source_text.save
      end

      it 'should leave the doi and the handle' do
        post :update_identifier

        item = ActiveFedora::Base.find(source_text.pid)
        expect(item.identifier).to eq ["DOI: 10.1080/10408440802272158", "http://hdl.handle.net/2186/ksl:test"]
        expect(response).to redirect_to bulk_update_path
      end
    end

    context 'when there is a handle link and a pid' do
      before :each do
        sign_in admin
        source_text.identifier = ["ksl:test", "http://hdl.handle.net/2186/ksl:test"]
        source_text.save
      end

      it 'should only return the handle link' do
        post :update_identifier

        item = ActiveFedora::Base.find(source_text.pid)
        expect(item.identifier).to eq ["http://hdl.handle.net/2186/ksl:test"]
        expect(response).to redirect_to bulk_update_path
      end
    end

  end

end
