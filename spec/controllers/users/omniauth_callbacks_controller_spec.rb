# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable RSpec/NamedSubject
RSpec.describe Users::OmniauthCallbacksController, type: :controller do
  include Devise::Test::ControllerHelpers
  include Warden::Test::Helpers

  let(:user) { FactoryBot.create(:OmniAuthUser) }
  let(:identity) { UserIdentity.find_by(user: user) }

  before do
    request.env['devise.mapping'] = Devise.mappings[:user]
    Warden.test_mode!
    OmniAuth.config.test_mode = true
  end

  describe 'OmniAuth providers' do
    it 'facebook' do
      expect(User).to receive(:find_for_omniauth).and_return(user)
      get :facebook
      expect(subject).to be_signed_in
    end

    it 'google' do
      expect(User).to receive(:find_for_omniauth).and_return(user)
      get :google
      expect(subject).to be_signed_in
    end

    it 'github' do
      expect(User).to receive(:find_for_omniauth).and_return(user)
      get :github
      expect(subject).to be_signed_in
    end

    it 'linkedin' do
      expect(User).to receive(:find_for_omniauth).and_return(user)
      get :linkedin
      expect(subject).to be_signed_in
    end

    it 'twitter' do
      expect(User).to receive(:find_for_omniauth).and_return(user)
      get :twitter
      expect(subject).to be_signed_in
    end

    it 'windows_live' do
      expect(User).to receive(:find_for_omniauth).and_return(user)
      get :windows_live
      expect(subject).to be_signed_in
    end

    it 'amazon' do
      expect(User).to receive(:find_for_omniauth).and_return(user)
      get :amazon
      expect(subject).to be_signed_in
    end
  end

  describe 'deauthorize' do
    before do
      sign_in user
    end

    it 'is not allowed to remove the existing OmniAuth Connection if it is the only one' do
      expect_any_instance_of(ApplicationController).to receive(:ensure_signup_complete).and_return(true)
      get :deauthorize, params: {provider: identity.omniauth_provider}
      expect(flash['error']).to include(I18n.t('users.settings.identity_not_deleted', provider: OmniAuth::Utils.camelize(identity.omniauth_provider)))
    end

    it 'is allowed to remove the OmniAuth connection if the user chose a password' do
      expect_any_instance_of(ApplicationController).to receive(:ensure_signup_complete).and_return(true)
      user.password_autogenerated = false
      user.save!
      get :deauthorize, params: {provider: identity.omniauth_provider}
      expect(flash['success']).to include(I18n.t('users.settings.identity_deleted', provider: OmniAuth::Utils.camelize(identity.omniauth_provider)))
    end

    it 'is allowed to remove the OmniAuth connection if another OmniAuth connection is set up' do
      expect_any_instance_of(ApplicationController).to receive(:ensure_signup_complete).and_return(true)
      FactoryBot.create(:user_identity, omniauth_provider: 'secondProvider', user: user)
      get :deauthorize, params: {provider: identity.omniauth_provider}
      expect(flash['success']).to include(I18n.t('users.settings.identity_deleted', provider: OmniAuth::Utils.camelize(identity.omniauth_provider)))
    end

    it 'returns an error flash message if the connection was not destroyed' do
      expect_any_instance_of(ApplicationController).to receive(:ensure_signup_complete).and_return(true)
      FactoryBot.create(:user_identity, omniauth_provider: 'secondProvider', user: user)
      get :deauthorize, params: {provider: 'not existing'}
      expect(flash['error']).to include(I18n.t('users.settings.identity_not_deleted', provider: OmniAuth::Utils.camelize('not existing')))
    end
  end
end
# rubocop:enable RSpec/NamedSubject
