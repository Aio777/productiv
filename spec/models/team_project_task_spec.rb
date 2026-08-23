# frozen_string_literal: true

# spec/models/team_project_task_spec.rb
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
require 'rails_helper'

RSpec.describe TeamProjectTask, type: :model do
  describe '#overdue?' do
    context 'when the due date is before the current time' do
      it 'returns true' do
        task = FactoryBot.create(:team_project_task, due_date: 1.day.ago)

        expect(task.overdue?).to be true
      end
    end

    context 'when the due date is after the current time' do
      it 'returns false' do
        task = FactoryBot.create(:team_project_task, due_date: 1.day.from_now)

        expect(task.overdue?).to be false
      end
    end

    context 'when the due date is exactly now or very close to now' do
      it 'returns false when the due date is in the future by a small amount' do
        task = FactoryBot.create(:team_project_task, due_date: 1.second.from_now)

        expect(task.overdue?).to be false
      end
    end
  end
end
