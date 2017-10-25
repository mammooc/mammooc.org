# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Completion, type: :model do
  describe 'sorted_certificates' do
    let!(:completion) { FactoryBot.create(:completion) }
    let!(:certificate) { FactoryBot.create(:certificate, completion: completion) }
    let!(:record_of_achievement) { FactoryBot.create(:record_of_achievement, completion: completion) }
    let!(:confirmation_of_participation) { FactoryBot.create(:confirmation_of_participation, completion: completion) }

    it 'sorts the certificates with the type' do
      expect(completion.sorted_certificates).to match [confirmation_of_participation, record_of_achievement, certificate]
    end
  end
end
