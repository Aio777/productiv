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
FactoryBot.define do
  factory :notification do
    association :user
    message { "Test notification" }
    read { false }

    trait :with_invite do
      association :shared_invite
    end

    trait :with_team_task do
      association :team_project_task
    end

    trait :read do
      read { true }
    end
  end
end
