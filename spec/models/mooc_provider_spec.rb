# encoding: utf-8
# frozen_string_literal: true
require 'rails_helper'

RSpec.describe MoocProvider, type: :model do
  describe 'options for select mooc provider' do
    let!(:provider1) { FactoryGirl.create(:mooc_provider) }
    let!(:provider2) { FactoryGirl.create(:mooc_provider) }
    let!(:provider3) { FactoryGirl.create(:mooc_provider) }

    it 'returns array of name and id' do
      options = described_class.options_for_select
      expect(options).to match_array([[provider1.name, provider1.id], [provider2.name, provider2.id], [provider3.name, provider3.id]])
    end
  end
end
