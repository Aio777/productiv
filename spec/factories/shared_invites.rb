# == Schema Information
#
# Table name: shared_invites
#
#  id              :bigint           not null, primary key
#  email           :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  team_project_id :bigint           not null
#
# Indexes
#
#  index_shared_invites_on_team_project_id  (team_project_id)
#
# Foreign Keys
#
#  fk_rails_...  (team_project_id => team_projects.id)
#
FactoryBot.define do
  factory :shared_invite do
    association :team_project
    email { "test@example.com" }

    trait :for_user do
      transient do
        user { nil }
      end

      email { user.email }
    end
  end
end
