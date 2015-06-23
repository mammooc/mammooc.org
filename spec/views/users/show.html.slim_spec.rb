# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe 'users/show', type: :view do
  let(:user) { FactoryGirl.create(:fullUser) }

  before(:each) do
    @user = user
  end
end
