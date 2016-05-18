# encoding: utf-8
# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Users::RegistrationsController, type: :controller do
  include Devise::TestHelpers

  self.use_transactional_fixtures = false

  before(:all) do
    DatabaseCleaner.strategy = :truncation
  end

  after(:all) do
    DatabaseCleaner.strategy = :transaction
  end

  before(:each) do
    request.env['devise.mapping'] = Devise.mappings[:user]
  end

  context 'user registration' do
    it 'works with valid signup data' do
      post :create, user: {first_name: 'John', last_name: 'Doe', email: 'user@example.org', password: 'password', password_confirmation: 'password'}, terms_and_conditions_confirmation: true
      expect(subject.signed_in?).to be_truthy
    end

    it 'does not work without valid terms and conditions' do
      post :create, user: {first_name: 'John', last_name: 'Doe', email: 'user@example.org', password: 'password', password_confirmation: 'password'}
      expect(subject.signed_in?).to be_falsey
    end
  end

  context 'update user' do
    let(:user) { FactoryGirl.create(:user) }

    before(:each) do
      sign_in user
    end

    it 'works with a user where the password is not autogenerated' do
      put :update, user: {primary_email: 'new@example.com', current_password: user.password}
      expect(user.primary_email).to eql 'new@example.com'
    end

    it 'validates if the new primary email address is valid' do
      put :update, user: {primary_email: 'invalidexample.com', current_password: user.password}
      expect(user.primary_email).not_to eql 'invalidexample.com'
      expect(flash['error']).to include(I18n.t('devise.registrations.email.invalid'))
    end

    it 'validates if the new primary email address is already taken' do
      second_user = FactoryGirl.create(:user)
      put :update, user: {primary_email: second_user.primary_email, current_password: user.password}
      expect(user.primary_email).not_to eql second_user.primary_email
      expect(flash['error']).to include(I18n.t('devise.registrations.email.taken'))
    end

    it 'requires the old password if it was not autogenerated' do
      patch :update, user: {primary_email: 'new@example.com', current_password: 'wrong password'}
      expect(user.reload.primary_email).not_to eql 'new@example.com'
    end

    it 'does not require the password if it was autogenerated' do
      user.password_autogenerated = true
      user.save!
      patch :update, user: {primary_email: 'new@example.com'}
      expect(user.primary_email).to eql 'new@example.com'
      expect(user.reload.password_autogenerated).to eql true
    end

    it 'removes the password autogenerated flag if the user sets his own password' do
      user.password_autogenerated = true
      user.save!
      patch :update, user: {password: '12345678', password_confirmation: '12345678'}
      expect(user.reload.password_autogenerated).to eql false
    end

    it 'does not remove the password autogenerated flag if the new password could not be used' do
      user.password_autogenerated = true
      user.save!
      sign_in user
      patch :update, user: {password: '12345678', password_confirmation: '87654321'}
      expect(user.reload.password_autogenerated).to eql true
    end

    it 'returns the changed primary email address if the update was not successful' do
      expect_any_instance_of(described_class).to receive(:update_resource).and_return(false)
      patch :update, user: {primary_email: 'changed@example.com'}
      expect(session[:resource]['primary_email']).to eql 'changed@example.com'
    end

    it 'does not return the primary email address if the address was autogenerated and the update was not successful' do
      expect_any_instance_of(described_class).to receive(:update_resource).and_return(false)
      expect_any_instance_of(ApplicationController).to receive(:ensure_signup_complete).and_return(true)
      expect_any_instance_of(UserEmail).to receive(:autogenerated?).and_return(true)
      patch :update, user: {password: '12345678', password_confirmation: '87654321'}
      expect(session[:resource]['primary_email']).to be_nil
    end

    it 'updates an auto-generated email address when finishing sign up' do
      identity = FactoryGirl.create(:user_identity, user: user)
      user.password_autogenerated = true
      user.primary_email = "autogenerated@#{identity.provider_user_id}-#{identity.omniauth_provider}.com".downcase
      user.save!
      expect(user.emails.find_by(address: user.primary_email).autogenerated?).to be_truthy
      patch :finish_signup, user: {primary_email: 'new@example.com'}
      user.reload
      expect(user.primary_email).to eql 'new@example.com'
    end

    it 'updates an auto-generated email address successfully' do
      identity = FactoryGirl.create(:user_identity, user: user)
      user.password_autogenerated = true
      user.primary_email = "autogenerated@#{identity.provider_user_id}-#{identity.omniauth_provider}.com".downcase
      user.save!
      expect(user.emails.find_by(address: user.primary_email).autogenerated?).to be_truthy
      put :update, user: {primary_email: 'new@example.com'}
      user.reload
      expect(user.primary_email).to eql 'new@example.com'
    end
  end

  context 'update OmniAuth user' do
    let(:user) { FactoryGirl.create(:OmniAuthUser) }

    before(:each) do
      sign_in user
    end

    it 'updates an auto-generated email address especially with an OmniAuth user (through finish sign up)' do
      expect(user.emails.find_by(address: user.primary_email).autogenerated?).to be_truthy
      patch :finish_signup, user: {primary_email: 'new@example.com'}
      user.reload
      expect(user.primary_email).to eql 'new@example.com'
    end

    it 'updates an auto-generated email address especially with an OmniAuth user (using the update method)' do
      expect(user.emails.find_by(address: user.primary_email).autogenerated?).to be_truthy
      put :update, user: {primary_email: 'new@example.com'}
      user.reload
      expect(user.primary_email).to eql 'new@example.com'
    end
  end
end
