require 'rails_helper'

RSpec.describe User, :type => :model do

  it "should have valid factory" do
    expect(FactoryGirl.build_stubbed(:user)).to be_valid
  end

  it "should require first name" do
    expect(FactoryGirl.build_stubbed(:user, :first_name => '')).not_to be_valid
  end

  it "should require last name" do
    expect(FactoryGirl.build_stubbed(:user, :last_name => '')).not_to be_valid
  end

  it "should require email" do
    expect(FactoryGirl.build_stubbed(:user, :email => '')).not_to be_valid
  end
end
