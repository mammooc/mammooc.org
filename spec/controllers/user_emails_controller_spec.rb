# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserEmailsController, type: :controller do
  let(:user) { User.create!(first_name: 'Max', last_name: 'Mustermann', password: '12345678') }
  let!(:primary_email) { FactoryBot.create(:user_email, user: user, is_primary: true) }

  let(:valid_attributes) { {address: 'test@example.com', is_primary: false, user_id: user.id} }

  before do
    sign_in user
  end

  describe 'mark as deleted' do
    let(:second_email) { FactoryBot.create(:user_email, user: user, is_primary: false) }
    let(:third_email) { FactoryBot.create(:user_email, user: user, is_primary: false) }

    it 'adds the specified email to session variable' do
      get :mark_as_deleted, params: {format: :json, id: second_email.id}
      expect(session[:deleted_user_emails]).to match([second_email.id])
    end

    it 'adds more than one email to session variable' do
      get :mark_as_deleted, params: {id: second_email.id, format: :json}
      get :mark_as_deleted, params: {id: third_email.id, format: :json}
      expect(session[:deleted_user_emails]).to match([second_email.id, third_email.id])
    end
  end
end
