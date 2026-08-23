# == Schema Information
#
# Table name: team_project_members
#
#  id                     :bigint           not null, primary key
#  joined_at              :datetime         not null
#  leaderboard_visibility :boolean          default(TRUE)
#  points                 :integer          default(0), not null
#  role                   :string           default("team_member")
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  team_project_id        :bigint           not null
#  user_id                :bigint           not null
#
# Indexes
#
#  index_team_project_members_on_team_project_id  (team_project_id)
#  index_team_project_members_on_user_id          (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (team_project_id => team_projects.id)
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :team_project_member do
    association :user
    association :team_project
    # association :radar_rating
    

    role { "team_member" }
    joined_at { Time.current }

    trait :team_lead do
      role { "team_lead" }
    end
  end
end
