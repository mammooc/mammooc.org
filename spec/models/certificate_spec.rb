# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe Certificate, type: :model do
  describe 'classification' do
    let(:completion) { FactoryGirl.create(:completion) }
    let(:confirmation_of_participation) { FactoryGirl.create(:confirmation_of_participation) }
    let(:record_of_achievement) { FactoryGirl.create(:record_of_achievement) }
    let(:certificate) { FactoryGirl.create(:certificate) }
    let(:other_document) { FactoryGirl.create(:certificate, document_type: 'other_document') }

    it 'returns 0 for confirmation_of_participation' do
      expect(confirmation_of_participation.classification).to eql 0
    end

    it 'returns 1 for record_of_achievement' do
      expect(record_of_achievement.classification).to eql 1
    end

    it 'returns 2 for certificate' do
      expect(certificate.classification).to eql 2
    end

    it 'returns 3 for all kind of other documents' do
      expect(other_document.classification).to eql 3
    end
  end
end
