require 'spec_helper'

describe SubmitController do

  describe '#index' do
    it 'gets the index page' do
      get :index
      expect(response).to be_successful
      expect(response).to render_template(:index)
    end
  end

  describe '#submit' do

    context 'when content is successfully submitted' do
      it 'should redirect to the thank you page' do
        # TODO: Update this to pass in test values when the form is created
        post :submit
        expect(response).to redirect_to '/submit/thanks'
      end
    end
  end

  describe '#thanks' do
    it 'shows the Thanks for submitting page' do
      get :thanks
      expect(response).to be_successful
      expect(response).to render_template(:thanks)
    end
  end

end
