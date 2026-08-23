# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserService, type: :service do
  describe '.upgrade_user_role' do
    let!(:subscriber) do
      FactoryBot.create(
        :user,
        first_name: 'Old',
        last_name: 'Subscriber',
        email: 'old_subscriber@example.com',
        role: 'subscriber',
        was_subscriber: true,
        password: 'Password@1234',
        password_confirmation: 'Password@1234'
      )
    end

    let(:admin_user_params) do
      {
        first_name: 'New',
        last_name: 'Admin',
        email: 'new_admin@example.com',
        role: 'admin'
      }
    end

    it 'destroys the old user and creates a new user with the admin params' do
      old_user_id = subscriber.id

      new_user = described_class.upgrade_user_role(subscriber, admin_user_params)

      expect(User.exists?(old_user_id)).to be(false)

      expect(new_user).to be_persisted
      expect(new_user.first_name).to eq('New')
      expect(new_user.last_name).to eq('Admin')
      expect(new_user.email).to eq('new_admin@example.com')
      expect(new_user.role).to eq('admin')
      expect(new_user.was_subscriber).to be(false)
    end

    it 'preserves the old encrypted password' do
      old_encrypted_password = subscriber.encrypted_password

      new_user = described_class.upgrade_user_role(subscriber, admin_user_params)

      expect(new_user.encrypted_password).to eq(old_encrypted_password)
    end

    it 'deletes shared invites matching the old user email' do
      FactoryBot.create(:shared_invite, email: subscriber.email)

      expect do
        described_class.upgrade_user_role(subscriber, admin_user_params)
      end.to change { SharedInvite.where(email: subscriber.email).count }.from(1).to(0)
    end
  end
end
