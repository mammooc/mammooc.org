# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :group_invitation do
    association :group_id, factory: :group
    sequence(:token) { SecureRandom.urlsafe_base64(Settings.token_length) }
    expiry_date Settings.token_expiry_date
    used false
  end

  factory :group_invitation_with_fixed_token, class: GroupInvitation do
    association :group_id, factory: :group
    token 'b4GOKm4pOYU_-BOXcrUGDg'
    expiry_date Settings.token_expiry_date
    used false
  end
end
