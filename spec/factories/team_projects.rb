# == Schema Information
#
# Table name: team_projects
#
#  id                  :bigint           not null, primary key
#  description         :string
#  image_path          :string
#  leaderboard_visible :boolean          default(TRUE)
#  name                :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
FactoryBot.define do
  factory :team_project do
    sequence(:name) { |n| "Project #{n}" }
    description { "Test project description" }
    image_path { "mixed-theme.jpg" }
  end
end