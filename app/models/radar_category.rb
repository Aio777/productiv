# frozen_string_literal: true

# == Schema Information
#
# Table name: radar_categories
#
#  id              :bigint           not null, primary key
#  name            :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  team_project_id :bigint           not null
#
# Indexes
#
#  index_radar_categories_on_team_project_id  (team_project_id)
#
# Foreign Keys
#
#  fk_rails_...  (team_project_id => team_projects.id)
#
class RadarCategory < ApplicationRecord
  belongs_to :team_project
  has_many :radar_ratings, dependent: :destroy
end
