# frozen_string_literal: true

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
class RadarRating < ApplicationRecord
  validates :category_rating,
            numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 5 }

  belongs_to :radar_category
  belongs_to :team_project_member
  belongs_to :team_project
end
