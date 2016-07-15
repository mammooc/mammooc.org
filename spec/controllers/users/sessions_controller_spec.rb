# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Users::SessionsController, type: :controller do
  include Devise::Test::ControllerHelpers
  include Warden::Test::Helpers

  let(:user) { FactoryGirl.create(:user) }

  before(:each) do
    request.env['devise.mapping'] = Devise.mappings[:user]
    Warden.test_mode!
  end

  it 'works with valid sign_in data' do
    post :create, params: {user: {primary_email: user.primary_email, password: user.password}}
    expect(subject.signed_in?).to be_truthy
  end

  it 'does not work without valid terms and conditions' do
    post :create, params: {user: {primary_email: 'nosuchuser@example.com', password: '123456789'}}
    expect(subject.signed_in?).to be_falsey
  end

  it 'stores the email address if user could not be logged in' do
    post :create, params: {user: {primary_email: user.primary_email, password: 'wrong'}}
    expect(session[:resource]['primary_email']).to eq user.primary_email
  end

  it 'updates the valid_until session info for any omniauth hash' do
    authentication_info = OmniAuth::AuthHash.new(
      provider: 'google',
      uid: '123',
      info: {
        email: user.primary_email,
        verified: false
      }
    )
    session['devise.google_data'] = authentication_info
    valid_until = Time.zone.now + 10.minutes
    session['devise.google_data']['valid_until'] = valid_until
    get :new
    expect(session['devise.google_data']['valid_until']).not_to eq valid_until
  end

  it 'deletes omniauth infos if they are not valid any more' do
    authentication_info = OmniAuth::AuthHash.new(
      provider: 'google',
      uid: '123',
      info: {
        email: user.primary_email,
        verified: false
      }
    )
    session['devise.google_data'] = authentication_info
    valid_until = Time.zone.now - 10.minutes
    session['devise.google_data']['valid_until'] = valid_until
    get :new
    expect(session['devise.google_data']).to be_nil
  end

  it 'deletes omniauth infos if required' do
    authentication_info = OmniAuth::AuthHash.new(
      provider: 'google',
      uid: '123',
      info: {
        email: user.primary_email,
        verified: false
      }
    )
    session['devise.google_data'] = authentication_info
    valid_until = Time.zone.now + 10.minutes
    session['devise.google_data']['valid_until'] = valid_until
    get :cancel_add_identity
    expect(session['devise.google_data']).to be_nil
  end

  it 'adds identity to user if valid' do
    authentication_info = OmniAuth::AuthHash.new(
      provider: 'google',
      uid: '123',
      info: {
        email: user.primary_email,
        verified: false
      }
    )
    session['devise.google_data'] = authentication_info
    valid_until = Time.zone.now + 10.minutes
    session['devise.google_data']['valid_until'] = valid_until
    user = FactoryGirl.create(:user)
    expect { post :create, params: {user: {primary_email: user.primary_email, password: '12345678'}} }.to change { UserIdentity.where(user_id: user.id).count }.by 1
    expect(flash['success']).to include I18n.t('users.sign_in_up.identity_merged', providers: 'Google')
  end

  it 'does not add identity to user if it is no longer valid' do
    authentication_info = OmniAuth::AuthHash.new(
      provider: 'google',
      uid: '123',
      info: {
        email: user.primary_email,
        verified: false
      }
    )
    session['devise.google_data'] = authentication_info
    valid_until = Time.zone.now - 10.minutes
    session['devise.google_data']['valid_until'] = valid_until
    user = FactoryGirl.create(:user)
    expect { post :create, params: {user: {primary_email: user.primary_email, password: '12345678'}} }.not_to change { UserIdentity.where(user_id: user.id).count }
  end
end
