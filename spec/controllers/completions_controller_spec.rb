# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe CompletionsController, type: :controller do
  let(:user) { FactoryGirl.create(:user) }

  let(:course) { FactoryGirl.create(:course) }

  let(:valid_attributes) do
    {user: user, course: course}
  end

  before(:each) do
    sign_in user
  end

  describe 'GET index' do
    it 'assigns all completions as @completions' do
      completion = Completion.create! valid_attributes
      get :index, user_id: user
      expect(assigns(:completions)).to eq([completion])
    end
  end
end
