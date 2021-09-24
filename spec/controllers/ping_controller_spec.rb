# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PingController, type: :controller do
  describe 'index' do

    let(:controller) { instance_double(described_class) }

    before do
      allow(described_class).to receive(:new).and_return(controller)
      allow(controller).to receive(:redis_connected!).and_return(true)
    end

    it 'returns the wanted page and answer with HTTP Status 200' do
      get :index

      expect(response).to have_http_status :ok
    end
  end
end
