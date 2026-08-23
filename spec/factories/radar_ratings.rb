# == Schema Information
#
# Table name: radar_ratings
#
#  id                     :bigint           not null, primary key
#  category_rating        :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  radar_category_id      :bigint           not null
#  team_project_id        :bigint           not null
#  team_project_member_id :bigint
#
# Indexes
#
#  index_radar_ratings_on_radar_category_id       (radar_category_id)
#  index_radar_ratings_on_team_project_id         (team_project_id)
#  index_radar_ratings_on_team_project_member_id  (team_project_member_id)
#
# Foreign Keys
#
#  fk_rails_...  (radar_category_id => radar_categories.id)
#  fk_rails_...  (team_project_id => team_projects.id)
#  fk_rails_...  (team_project_member_id => team_project_members.id)
#
FactoryBot.define do
  factory :radar_rating do
    association :team_project
    association :radar_category
    association :team_project_member

    category_rating { 3 }
  end
end
