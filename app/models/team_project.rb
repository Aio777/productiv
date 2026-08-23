# frozen_string_literal: true

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
class TeamProject < ApplicationRecord
  has_many :team_project_members, dependent: :destroy
  has_many :users, through: :team_project_members, source: :user

  has_many :team_project_tasks, dependent: :destroy
  has_many :radar_categories, dependent: :destroy
  has_many :radar_ratings, dependent: :destroy
  has_many :team_task_assignments, through: :team_project_tasks, dependent: :destroy
  has_many :shared_invites, dependent: :destroy

  has_one :team_lead_membership,
          -> { where(role: 'team_lead') },
          class_name: 'TeamProjectMember', dependent: :destroy

  has_one :team_lead,
          through: :team_lead_membership,
          source: :user, dependent: :destroy

  def project_progress
    tasks = team_project_tasks.to_a

    total = tasks.length
    return 0 if total.zero?

    completed = tasks.count(&:status_complete)

    ((completed.to_f / total) * 100).round
  end

  def leaderboard_visible?
    leaderboard_visible
  end
end
