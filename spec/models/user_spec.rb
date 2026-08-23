# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  failed_attempts        :integer          default(0), not null
#  first_name             :string           default("")
#  invitation_accepted_at :datetime
#  invitation_created_at  :datetime
#  invitation_limit       :integer
#  invitation_sent_at     :datetime
#  invitation_token       :string
#  invited_by_type        :string
#  last_name              :string           default("")
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string
#  layout                 :integer
#  locked_at              :datetime
#  points                 :integer          default(0), not null
#  registration_ip        :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  role                   :string           default("subscriber")
#  sign_in_count          :integer          default(0), not null
#  unlock_token           :string
#  was_subscriber         :boolean          default(TRUE), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  invited_by_id          :integer
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_invitation_token      (invitation_token) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#unread_notifications_count' do
    let(:user) { FactoryBot.create(:user, role: 'subscriber') }

    before do
      FactoryBot.create(:notification, user: user, read: false)
      FactoryBot.create(:notification, user: user, read: false)
      FactoryBot.create(:notification, user: user, read: true)
    end

    it 'returns the number of unread notifications for the user' do
      expect(user.unread_notifications_count).to eq(2)
    end

    it 'does not count notifications belonging to another user' do
      other_user = FactoryBot.create(:user)

      FactoryBot.create(:notification, user: other_user, read: false)

      expect(user.unread_notifications_count).to eq(2)
    end
  end

  describe '#admin?' do
    it 'returns true when the user role is admin' do
      user = FactoryBot.build(:user, role: 'admin')

      expect(user.admin?).to be true
    end

    it 'returns false when the user role is not admin' do
      user = FactoryBot.build(:user, role: 'subscriber')

      expect(user.admin?).to be false
    end
  end

  describe '#reporter?' do
    it 'returns true when the user role is reporter' do
      user = FactoryBot.build(:user, role: 'reporter')

      expect(user.reporter?).to be true
    end

    it 'returns false when the user role is not reporter' do
      user = FactoryBot.build(:user, role: 'admin')

      expect(user.reporter?).to be false
    end
  end

  describe '#subscriber?' do
    it 'returns true when the user role is subscriber' do
      user = FactoryBot.build(:user, role: 'subscriber')

      expect(user.subscriber?).to be true
    end

    it 'returns false when the user role is not subscriber' do
      user = FactoryBot.build(:user, role: 'reporter')

      expect(user.subscriber?).to be false
    end
  end

  describe '#create_default_individual_project' do
    it 'creates a default individual project after user creation' do
      user = FactoryBot.create(:user, role: 'subscriber')

      expect(user.individual_project).to be_present
    end
  end
end
