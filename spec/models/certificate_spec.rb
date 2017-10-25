# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Certificate, type: :model do
  describe 'classification' do
    let(:completion) { FactoryBot.create(:completion) }
    let(:confirmation_of_participation) { FactoryBot.create(:confirmation_of_participation) }
    let(:record_of_achievement) { FactoryBot.create(:record_of_achievement) }
    let(:certificate) { FactoryBot.create(:certificate) }
    let(:other_document) { FactoryBot.create(:certificate, document_type: 'other_document') }

    it 'returns 0 for confirmation_of_participation' do
      expect(confirmation_of_participation.classification).to eq 0
    end

    it 'returns 1 for record_of_achievement' do
      expect(record_of_achievement.classification).to eq 1
    end

    it 'returns 2 for certificate' do
      expect(certificate.classification).to eq 2
    end

    it 'returns 3 for all kind of other documents' do
      expect(other_document.classification).to eq 3
    end
  end
end
