# frozen_string_literal: true
require 'rails_helper'

RSpec.describe UsersHelper, type: :helper do
  it 'returns :user for resource_name' do
    expect(resource_name).to eq :user
  end

  it 'returns @resource for a resource' do
    expect(resource.attributes).to eq User.new.attributes
  end

  it 'returns a devise_mapping if required' do
    expect(devise_mapping).to eq Devise.mappings[:user]
  end
end
