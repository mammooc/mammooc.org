# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Users', type: :request do
  before(:each) do
    sign_in_as_a_valid_user
  end
end
