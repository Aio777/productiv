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
FactoryBot.define do
  factory :team_project_task do
    association :team_project

    name { "Test Task" }
    due_date { 2.days.from_now }
    points { 10 }

    description { "Task description" }
    difficulty { "easy" }
    status_complete { false }
  end
end
