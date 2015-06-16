# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe UserEmailsController, type: :controller do

  let(:user) { User.create!(first_name: 'Max', last_name: 'Mustermann', password: '12345678') }
  let!(:primary_email) { FactoryGirl.create(:user_email, user: user, is_primary: true) }

  let(:valid_attributes) { { address: 'test@example.com', is_primary: false, user_id: user.id } }

  before(:each) do
    sign_in user
  end

  describe 'POST create' do
    describe 'with valid params' do
      it 'creates a new UserEmail' do
        expect do
          post :create, {user_email: valid_attributes}
        end.to change(UserEmail, :count).by(1)
      end

      it 'assigns a newly created email as @user_email' do
        post :create, {user_email: valid_attributes}
        expect(assigns(:user_email)).to be_a(UserEmail)
        expect(assigns(:user_email)).to be_persisted
      end

      it 'redirects to the created email' do
        post :create, {user_email: valid_attributes}
        expect(response).to redirect_to(user_email_path(assigns(:user_email)))
      end
    end
  end

  describe 'PUT update' do
    describe 'with valid params' do
      let(:new_attributes) { { address: 'newAddress@example.com', is_primary: false, user_id: user.id } }

      it 'updates the requested email' do
        email = UserEmail.create! valid_attributes
        put :update, {id: email.to_param, user_email: new_attributes}
        email.reload
        expect(email.address).to eq 'newAddress@example.com'
        expect(email.is_primary).to be false
        expect(email.user_id).to eq user.id
      end

      it 'assigns the requested email as @user_email' do
        email = UserEmail.create! valid_attributes
        put :update, {id: email.to_param, user_email: valid_attributes}
        expect(assigns(:user_email)).to eq(email)
      end

      it 'redirects to the email' do
        email = UserEmail.create! valid_attributes
        put :update, {id: email.to_param, user_email: valid_attributes}
        expect(response).to redirect_to(email)
      end
    end
  end

  describe 'DELETE destroy' do
    it 'destroys the requested email' do
      email = UserEmail.create! valid_attributes
      expect do
        delete :destroy, {id: email.to_param}
      end.to change(UserEmail, :count).by(-1)
    end

    it 'redirects to the emails list' do
      email = UserEmail.create! valid_attributes
      delete :destroy, {id: email.to_param}
      expect(response).to redirect_to(user_emails_url)
    end
  end

  describe 'mark as deleted' do
    let(:second_email) { FactoryGirl.create(:user_email, user: user, is_primary: false) }
    let(:third_email) { FactoryGirl.create(:user_email, user: user, is_primary: false) }

    it 'adds the specified email to session variable' do
      get :mark_as_deleted, format: :json, id: second_email.id
      expect(session[:deleted_user_emails]).to match([second_email.id])
    end

    it 'adds more than one email to session variable' do
      get :mark_as_deleted, id: second_email.id, format: :json
      get :mark_as_deleted, id: third_email.id, format: :json
      expect(session[:deleted_user_emails]).to match([second_email.id, third_email.id])
    end

  end
end
