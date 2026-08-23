# frozen_string_literal: true

# == Schema Information
#
# Table name: team_task_assignments
#
#  id                     :bigint           not null, primary key
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  team_project_member_id :bigint           not null
#  team_project_task_id   :bigint           not null
#
# Indexes
#
#  index_team_task_assignments_on_task_and_member         (team_project_task_id,team_project_member_id) UNIQUE
#  index_team_task_assignments_on_team_project_member_id  (team_project_member_id)
#  index_team_task_assignments_on_team_project_task_id    (team_project_task_id)
#
# Foreign Keys
#
#  fk_rails_...  (team_project_member_id => team_project_members.id)
#  fk_rails_...  (team_project_task_id => team_project_tasks.id)
#
class TeamTaskAssignment < ApplicationRecord
  belongs_to :team_project_task
  belongs_to :team_project_member

  has_one :user, through: :team_project_member
end
