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
FactoryBot.define do
  factory :team_task_assignment do
    association :team_project_task
    association :team_project_member
  end
end
