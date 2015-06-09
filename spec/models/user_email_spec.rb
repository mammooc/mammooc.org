# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe UserEmail, type: :model do
  describe 'creates new user emails' do
    let!(:user) { User.create!(first_name: 'Max', last_name: 'Mustermann', password: '12345678') }

    it 'create a primary email if it is the first one' do
      expect { described_class.create!(user: user, is_primary: true, address: 'max@example.com') }.not_to raise_error
    end

    it 'does not create a second primary address' do
      FactoryGirl.create(:user_email, user: user)
      expect { described_class.create!(user: user, is_primary: true, address: 'max@example.com') }.to raise_error
    end

    it 'does not allow to create a non primary address if no primary address is saved yet' do
      expect { described_class.create!(user: user, is_primary: false, address: 'max@example.com') }.to raise_error
    end

    it 'creates non primary addresses if a primary address is saved' do
      FactoryGirl.create(:user_email, user: user)
      expect { described_class.create!(user: user, is_primary: false, address: 'max1@example.com') }.not_to raise_error
      expect { described_class.create!(user: user, is_primary: false, address: 'max2@example.com') }.not_to raise_error
    end
  end

  describe 'update user emails' do
    let!(:user) { User.create!(first_name: 'Max', last_name: 'Mustermann', password: '12345678') }

    it 'is not allowed to remove the is_primary attribute without changing another address to the primary' do
      email = FactoryGirl.create(:user_email, user: user)
      email.is_primary = false
      expect { email.save! }.to raise_error
      expect(email).not_to be_valid
    end

    it 'is allowed to toggle the is_primary attribute between two addresses' do
      email1 = FactoryGirl.create(:user_email, user: user, is_primary: true)
      email2 = FactoryGirl.create(:user_email, user: user, is_primary: false)

      expect do
        described_class.transaction do
          email1.is_primary = false
          email2.is_primary = true
        end
      end.not_to raise_error
      expect(email1.is_primary).to be false
      expect(email2.is_primary).to be true
    end

    it 'is not allowed to add the is_primary attribute if another primary address exists' do
      FactoryGirl.create(:user_email, user: user, is_primary: true)
      email2 = FactoryGirl.create(:user_email, user: user, is_primary: false)
      email2.is_primary = true
      expect { email2.save! }.to raise_error
      expect(email2).not_to be_valid
    end
  end

  describe 'destroy user emails' do
    let!(:user) { User.create!(first_name: 'Max', last_name: 'Mustermann', password: '12345678') }

    it 'is allowed to destroy any non primary address' do
      FactoryGirl.create(:user_email, user: user, is_primary: true)
      email2 = FactoryGirl.create(:user_email, user: user, is_primary: false)
      expect { email2.destroy! }.not_to raise_error
      expect(email2.destroyed?).to be true
    end

    it 'is not allowed to destroy the primary address' do
      email = FactoryGirl.create(:user_email, user: user)
      expect do
        email.transaction do
          email.destroy!
          email.send(:validate_destroy)
        end
      end.to raise_error
      restored_email = described_class.find_by(email.attributes.except('created_at', 'updated_at'))
      expect(restored_email.attributes.except('created_at', 'updated_at')).to eql email.attributes.except('created_at', 'updated_at')
    end

    it 'is allowed to delete the primary address if another one is made primary' do
      email1 = FactoryGirl.create(:user_email, user: user, is_primary: true)
      email2 = FactoryGirl.create(:user_email, user: user, is_primary: false)

      expect do
        described_class.transaction do
          email2.is_primary = true
          email1.destroy!
          email2.save!
        end
      end.not_to raise_error
      expect(email2.reload.is_primary).to be true
      expect(email2).to be_valid
      expect(email1.destroyed?).to be true
    end

    it 'is allowed to delete a user email if no user exits' do
      email = FactoryGirl.create(:user_email, user: user)
      user.id = nil
      expect { email.destroy! }.not_to raise_error
      expect(email.destroyed?).to be true
    end
  end

  describe 'validate' do
    let!(:user) { User.create!(first_name: 'Max', last_name: 'Mustermann', password: '12345678') }

    context 'attribute is_verified' do
      it 'accepts true' do
        expect { described_class.create!(user: user, is_primary: true, address: 'max@example.com', is_verified: true) }.not_to raise_error
      end

      it 'accepts false' do
        expect { described_class.create!(user: user, is_primary: true, address: 'max@example.com', is_verified: false) }.not_to raise_error
      end

      it 'does not accepts nil' do
        expect { described_class.create!(user: user, is_primary: true, address: 'max@example.com', is_verified: nil) }.to raise_error
      end
    end

    context 'attribute address' do
      it 'accepts valid addresses' do
        expect { described_class.create!(user: user, is_primary: true, address: 'max@example.com') }.not_to raise_error
        expect { described_class.create!(user: user, is_primary: false, address: 'max@subdomain.example.com') }.not_to raise_error
      end

      it 'does not accept invalid addresses without reciever' do
        expect { described_class.create!(user: user, is_primary: true, address: '@example.com') }.to raise_error
      end

      it 'does not accept invalid addresses without @ or TLD' do
        expect { described_class.create!(user: user, is_primary: true, address: 'max') }.to raise_error
      end

      it 'does not accept invalid addresses without @' do
        expect { described_class.create!(user: user, is_primary: true, address: 'maxexample.com') }.to raise_error
      end

      it 'does not accept invalid addresses without TLD' do
        expect { described_class.create!(user: user, is_primary: true, address: 'max@examplecom') }.to raise_error
      end

      it 'does not accept invalid addresses with TLDs shorter then two characters' do
        expect { described_class.create!(user: user, is_primary: true, address: 'max@example.c') }.to raise_error
      end

      it 'does not accept invalid addresses starting with a dot or dash' do
        expect { described_class.create!(user: user, is_primary: true, address: '.max@example.com') }.to raise_error
        expect { described_class.create!(user: user, is_primary: true, address: '-max@example.com') }.to raise_error
      end

      it 'does not accept invalid domains starting with a dot or dash' do
        expect { described_class.create!(user: user, is_primary: true, address: 'max@.example.com') }.to raise_error
        expect { described_class.create!(user: user, is_primary: true, address: 'max@-example.com') }.to raise_error
      end
    end
  end

  describe 'autogenerated?' do
    let!(:user) { User.create!(first_name: 'Max', last_name: 'Mustermann', password: '12345678') }

    it 'response false if no user identity could be found' do
      email = described_class.create!(user: user, address: 'max@example.com', is_primary: true)
      expect(email.autogenerated?).to eql false
    end

    it 'response false if user identities are present but mail is not autogenerated' do
      email = described_class.create!(user: user, address: 'max@example.com', is_primary: true)
      UserIdentity.create!(user: user, omniauth_provider: 'provider1', provider_user_id: '123')
      UserIdentity.create!(user: user, omniauth_provider: 'provider2', provider_user_id: '456')
      expect(email.autogenerated?).to eql false
    end

    it 'response true if the mail address is autogenerated with the user identity' do
      identity = UserIdentity.create!(user: user, omniauth_provider: 'provider1', provider_user_id: '123')
      email = described_class.create!(user: user, address: "autogenerated@#{identity.provider_user_id}-#{identity.omniauth_provider}.com", is_primary: true)
      expect(email.autogenerated?).to eql true
    end
  end
end
