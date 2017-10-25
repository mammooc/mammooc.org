# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserEmail, type: :model do
  let!(:user) { User.create!(first_name: 'Max', last_name: 'Mustermann', password: '12345678') }

  describe 'creates new user emails' do
    it 'create a primary email if it is the first one' do
      expect { described_class.create!(user: user, is_primary: true, address: 'max@example.com') }.not_to raise_error
      expect(described_class.where(user: user, is_primary: true).count).to eq 1
    end

    it 'does not create a second primary address' do
      FactoryBot.create(:user_email, user: user)
      expect { described_class.create!(user: user, is_primary: true, address: 'max@example.com') }.to raise_error ActiveRecord::RecordInvalid
      expect(described_class.where(user: user, is_primary: true).count).to eq 1
    end

    it 'does not allow to create a non primary address if no primary address is saved yet' do
      expect { described_class.create!(user: user, is_primary: false, address: 'max@example.com') }.to raise_error ActiveRecord::RecordInvalid
    end

    it 'creates non primary addresses if a primary address is saved' do
      FactoryBot.create(:user_email, user: user)
      expect { described_class.create!(user: user, is_primary: false, address: 'max1@example.com') }.not_to raise_error
      expect { described_class.create!(user: user, is_primary: false, address: 'max2@example.com') }.not_to raise_error
    end
  end

  describe 'update user emails' do
    it 'is not allowed to remove the is_primary attribute without changing another address to the primary' do
      email = FactoryBot.create(:user_email, user: user)
      email.is_primary = false
      expect { email.save! }.to raise_error ActiveRecord::RecordInvalid
      expect(email).not_to be_valid
      expect(described_class.where(user: user, is_primary: true).count).to eq 1
    end

    it 'is allowed to toggle the is_primary attribute between two addresses' do
      email1 = FactoryBot.create(:user_email, user: user, is_primary: true)
      email2 = FactoryBot.create(:user_email, user: user, is_primary: false)

      expect do
        email2.change_to_primary_email
      end.not_to raise_error
      expect(email1.reload.is_primary).to be false
      expect(email2.reload.is_primary).to be true
      expect(described_class.where(user: user, is_primary: true).count).to eq 1
    end

    it 'is not allowed to add the is_primary attribute if another primary address exists' do
      FactoryBot.create(:user_email, user: user, is_primary: true)
      email2 = FactoryBot.create(:user_email, user: user, is_primary: false)
      email2.is_primary = true
      expect { email2.save! }.to raise_error ActiveRecord::RecordInvalid
      expect(email2).not_to be_valid
      expect(described_class.where(user: user, is_primary: true).count).to eq 1
    end
  end

  describe 'destroy user emails' do
    it 'is allowed to destroy any non primary address' do
      FactoryBot.create(:user_email, user: user, is_primary: true)
      email2 = FactoryBot.create(:user_email, user: user, is_primary: false)
      expect { email2.destroy! }.not_to raise_error
      expect(email2.destroyed?).to be true
    end

    it 'is not allowed to destroy the primary address' do
      skip 'spec beacuse it fails randomly on CircleCI'
      email = FactoryBot.create(:user_email, user: user, is_primary: true)
      expect { email.destroy! }.to raise_error ActiveRecord::RecordNotDestroyed
      expect(described_class.where(user: user, is_primary: true).count).to eq 1
    end

    it 'is allowed to delete the primary address if another one is made primary' do
      email1 = FactoryBot.create(:user_email, user: user, is_primary: true)
      email2 = FactoryBot.create(:user_email, user: user, is_primary: false)

      expect do
        email2.change_to_primary_email
        email1.reload.destroy!
      end.not_to raise_error

      expect(email2.reload.is_primary).to be true
      expect(email2).to be_valid
      expect(email1.destroyed?).to be true
      expect(described_class.where(user: user, is_primary: true).count).to eq 1
    end
  end

  describe 'validate' do
    context 'attribute is_verified' do
      it 'accepts true' do
        expect { described_class.create!(user: user, is_primary: true, address: 'max@example.com', is_verified: true) }.not_to raise_error
      end

      it 'accepts false' do
        expect { described_class.create!(user: user, is_primary: true, address: 'max@example.com', is_verified: false) }.not_to raise_error
      end

      it 'does not accepts nil' do
        expect { described_class.create!(user: user, is_primary: true, address: 'max@example.com', is_verified: nil) }.to raise_error ActiveRecord::RecordInvalid
      end
    end

    context 'attribute address' do
      it 'accepts valid addresses' do
        expect { described_class.create!(user: user, is_primary: true, address: 'max@example.com') }.not_to raise_error
        expect { described_class.create!(user: user, is_primary: false, address: 'max@subdomain.example.com') }.not_to raise_error
      end

      it 'does not accept invalid addresses without reciever' do
        expect { described_class.create!(user: user, is_primary: true, address: '@example.com') }.to raise_error ActiveRecord::RecordInvalid
      end

      it 'does not accept invalid addresses without @ or TLD' do
        expect { described_class.create!(user: user, is_primary: true, address: 'max') }.to raise_error ActiveRecord::RecordInvalid
      end

      it 'does not accept invalid addresses without @' do
        expect { described_class.create!(user: user, is_primary: true, address: 'maxexample.com') }.to raise_error ActiveRecord::RecordInvalid
      end

      it 'does not accept invalid addresses without TLD' do
        expect { described_class.create!(user: user, is_primary: true, address: 'max@examplecom') }.to raise_error ActiveRecord::RecordInvalid
      end

      it 'does not accept invalid addresses with TLDs shorter then two characters' do
        expect { described_class.create!(user: user, is_primary: true, address: 'max@example.c') }.to raise_error ActiveRecord::RecordInvalid
      end

      it 'does not accept invalid addresses starting with a dot or dash' do
        expect { described_class.create!(user: user, is_primary: true, address: '.max@example.com') }.to raise_error ActiveRecord::RecordInvalid
        expect { described_class.create!(user: user, is_primary: true, address: '-max@example.com') }.to raise_error ActiveRecord::RecordInvalid
      end

      it 'does not accept invalid domains starting with a dot or dash' do
        expect { described_class.create!(user: user, is_primary: true, address: 'max@.example.com') }.to raise_error ActiveRecord::RecordInvalid
        expect { described_class.create!(user: user, is_primary: true, address: 'max@-example.com') }.to raise_error ActiveRecord::RecordInvalid
      end
    end
  end

  describe 'autogenerated?' do
    it 'response false if no user identity could be found' do
      email = described_class.create!(user: user, address: 'max@example.com', is_primary: true)
      expect(email.autogenerated?).to eq false
    end

    it 'response false if user identities are present but mail is not autogenerated' do
      email = described_class.create!(user: user, address: 'max@example.com', is_primary: true)
      UserIdentity.create!(user: user, omniauth_provider: 'provider1', provider_user_id: '123')
      UserIdentity.create!(user: user, omniauth_provider: 'provider2', provider_user_id: '456')
      expect(email.autogenerated?).to eq false
    end

    it 'response true if the mail address is autogenerated with the user identity' do
      identity = UserIdentity.create!(user: user, omniauth_provider: 'provider1', provider_user_id: '123')
      email = described_class.create!(user: user, address: "autogenerated@#{identity.provider_user_id}-#{identity.omniauth_provider}.com", is_primary: true)
      expect(email.autogenerated?).to eq true
    end
  end

  describe 'change_to_primary_email' do
    let!(:email1) { FactoryBot.create(:user_email, user: user, is_primary: true) }
    let!(:email2) { FactoryBot.create(:user_email, user: user, is_primary: false) }

    it 'changes the is_primary attribute to true and changes the existing primary_email.is_primary to false' do
      email2.change_to_primary_email
      expect(described_class.find(email2.id).is_primary).to be true
      expect(described_class.find(email1.id).is_primary).to be false
      expect(described_class.where(user: user, is_primary: true).count).to eq 1
    end

    it 'changes is_primary of an already primary_email' do
      email1.change_to_primary_email
      expect(described_class.find(email2.id).is_primary).to be false
      expect(described_class.find(email1.id).is_primary).to be true
      expect(described_class.where(user: user, is_primary: true).count).to eq 1
    end
  end
end
