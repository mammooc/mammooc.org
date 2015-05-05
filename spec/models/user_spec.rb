# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe User, type: :model do
  it 'has valid factory' do
    expect(FactoryGirl.build_stubbed(:user)).to be_valid
  end

  it 'requires first name' do
    expect(FactoryGirl.build_stubbed(:user, first_name: '')).not_to be_valid
  end

  it 'requires last name' do
    expect(FactoryGirl.build_stubbed(:user, last_name: '')).not_to be_valid
  end

  it 'requires email' do
    expect(FactoryGirl.build_stubbed(:user, email: '')).not_to be_valid
  end
end
