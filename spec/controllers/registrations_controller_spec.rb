require 'rails_helper'

RSpec.describe Users::RegistrationsController, :type => :controller do

  include Devise::TestHelpers

  before(:each) do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  it "should work with valid signup data" do
    post :create, { user: { first_name: 'John', last_name: 'Doe', email: "user@example.org", password: "password", password_confirmation: "password" }, terms_and_conditions_confirmation: true }
    expect(subject.signed_in?).to be_truthy
  end
  it "should not work without valid terms and conditions" do
    post :create, { user: { first_name: 'John', last_name: 'Doe', email: "user@example.org", password: "password", password_confirmation: "password" } }
    expect(subject.signed_in?).to be_falsey
  end
end