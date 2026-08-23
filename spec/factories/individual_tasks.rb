# == Schema Information
#
# Table name: individual_tasks
#
#  id                    :bigint           not null, primary key
#  description           :string
#  difficulty            :string
#  due_date              :datetime         not null
#  name                  :string
#  points                :integer
#  read                  :boolean
#  reminder_date         :datetime
#  status_complete       :boolean          default(FALSE), not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  individual_project_id :bigint           not null
#
# Indexes
#
#  index_individual_tasks_on_individual_project_id  (individual_project_id)
#
# Foreign Keys
#
#  fk_rails_...  (individual_project_id => individual_projects.id)
#
FactoryBot.define do
  factory :individual_task do
    name { "Task Name" }
    due_date { 2.week.from_now }
    reminder_date { 1.week.from_now }
    description { "Sample description for Task Name" }
    difficulty { "easy" }
    points { 10 }
    status_complete { false }
  end
end
