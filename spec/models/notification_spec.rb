# frozen_string_literal: true

# == Schema Information
#
# Table name: notifications
#
#  id                   :bigint           not null, primary key
#  message              :string           not null
#  read                 :boolean          default(FALSE), not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  individual_task_id   :bigint
#  shared_invite_id     :bigint
#  team_project_task_id :bigint
#  user_id              :bigint           not null
#
# Indexes
#
#  index_notifications_on_individual_task_id    (individual_task_id)
#  index_notifications_on_shared_invite_id      (shared_invite_id)
#  index_notifications_on_team_project_task_id  (team_project_task_id)
#  index_notifications_on_user_id               (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (individual_task_id => individual_tasks.id)
#  fk_rails_...  (shared_invite_id => shared_invites.id)
#  fk_rails_...  (team_project_task_id => team_project_tasks.id)
#  fk_rails_...  (user_id => users.id)
#
#  fk_rails_...  (individual_task_id => individual_tasks.id)
#  fk_rails_...  (shared_invite_id => shared_invites.id)
#  fk_rails_...  (team_project_task_id => team_project_tasks.id)
#  fk_rails_...  (user_id => users.id)
require 'rails_helper'

RSpec.describe Notification, type: :model do
  describe '.all_read_for?' do
    let!(:user) { FactoryBot.create(:user) }
    let!(:other_user) { FactoryBot.create(:user) }

    it 'returns true when the user has no unread notifications' do
      FactoryBot.create(:notification, user: user, read: true)

      expect(described_class.all_read_for?(user)).to be(true)
    end

    it 'returns false when the user has unread notifications' do
      FactoryBot.create(:notification, user: user, read: false)

      expect(described_class.all_read_for?(user)).to be(false)
    end

    it 'ignores unread notifications belonging to other users' do
      FactoryBot.create(:notification, user: user, read: true)
      FactoryBot.create(:notification, user: other_user, read: false)

      expect(described_class.all_read_for?(user)).to be(true)
    end

    it 'returns true when the user has no notifications' do
      expect(described_class.all_read_for?(user)).to be(true)
    end
  end
end
