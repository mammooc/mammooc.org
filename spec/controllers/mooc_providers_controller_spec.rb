# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MoocProvidersController, type: :controller do
  let(:valid_attributes) do
    {name: 'open_mammooc', logo_id: 'logo_open_mammooc.png'}
  end

  let(:user) { FactoryBot.create(:user) }

  before do
    sign_in user
  end

  describe 'GET index' do
    it 'assigns all mooc_providers as @mooc_providers' do
      mooc_provider = MoocProvider.create! valid_attributes
      get :index, params: {format: :json}
      expect(assigns(:mooc_providers)).to eq([mooc_provider])
    end
  end
end
