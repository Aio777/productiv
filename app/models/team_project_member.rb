# frozen_string_literal: true

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
class TeamProjectMember < ApplicationRecord
  validates :joined_at, presence: true
  validates :role, inclusion: { in: %w[team_lead team_member] }
  validates :role, uniqueness: { scope: :team_project_id }, if: -> { role == 'team_lead' }

  belongs_to :team_project
  belongs_to :user

  has_many :team_task_assignments, dependent: :destroy
  has_many :team_project_tasks, through: :team_task_assignments
  has_many :radar_ratings, dependent: :destroy

  before_validation :set_joined_at, on: :create

  def radar_rating(category)
    radar_ratings.find_by(radar_category: category)&.category_rating.presence || 3
  end

  def leaderboard_visibility?
    leaderboard_visibility
  end

  private

  def set_joined_at
    self.joined_at ||= Time.current
  end
end
