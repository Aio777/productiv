# frozen_string_literal: true

# == Schema Information
#
# Table name: team_project_tasks
#
#  id              :bigint           not null, primary key
#  description     :string
#  difficulty      :string
#  due_date        :datetime         not null
#  name            :string
#  points          :integer
#  read            :boolean
#  reminder_date   :datetime
#  status_complete :boolean          default(FALSE), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  team_project_id :bigint           not null
#
# Indexes
#
#  index_team_project_tasks_on_team_project_id  (team_project_id)
#
# Foreign Keys
#
#  fk_rails_...  (team_project_id => team_projects.id)
#
class TeamProjectTask < ApplicationRecord
  validates :name, presence: true
  validates :due_date, presence: true
  validates :reminder_date, presence: true, allow_nil: true
  validates :description, presence: true, allow_nil: true
  validates :difficulty, inclusion: { in: %w[easy medium hard], message: '%<value> is not a valid difficulty' },
                         allow_nil: true
  validates :points, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: false

  belongs_to :team_project

  has_many :team_task_assignments, dependent: :destroy
  has_many :team_project_members, through: :team_task_assignments, source: :team_project_member
  has_many :assigned_members, through: :team_task_assignments, source: :team_project_member
  has_many :notifications, dependent: :destroy

  def overdue?
    due_date && due_date < Time.current
  end
end
