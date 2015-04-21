require 'rails_helper'


RSpec.describe Users::SessionsController, :type => :controller do

  include Devise::TestHelpers
  include Warden::Test::Helpers


  let(:user) {FactoryGirl.create(:user)}

  before(:each) do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    Warden.test_mode!
  end

  it "should work with valid sign_in data" do
    post :create, { user: { email: user.email, password: user.password}}
    expect(subject.signed_in?).to be_truthy
  end
  it "should not work without valid terms and conditions" do
    post :create, { user: { email: 'nosuchuser@example.com', password: '123456789'}}
    expect(subject.signed_in?).to be_falsey
  end
end