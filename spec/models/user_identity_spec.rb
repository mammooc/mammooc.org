# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserIdentity, type: :model do
  describe 'find_for_omniauth' do
    let(:user) { FactoryBot.create(:OmniAuthUser) }

    it 'finds the user identiy if present' do
      identity = described_class.find_by(user: user)
      authentication_info = OmniAuth::AuthHash.new(provider: identity.omniauth_provider, uid: identity.provider_user_id)
      expect(described_class.find_for_omniauth(authentication_info)).to eq identity
    end

    it 'returns a new user identiy if no existing could be found' do
      identity = described_class.find_by(user: user)
      authentication_info = OmniAuth::AuthHash.new(provider: identity.omniauth_provider, uid: 'other_user')
      expect(new_identity = described_class.find_for_omniauth(authentication_info)).not_to eq identity
      expect(new_identity).to be_valid
      expect(new_identity.omniauth_provider).to eq authentication_info.provider
      expect(new_identity.provider_user_id).to eq authentication_info.uid
      expect(new_identity.user).to be_nil
    end
  end
end
