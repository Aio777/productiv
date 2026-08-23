# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Task history performance', type: :feature do
  let!(:subscriber) do
    FactoryBot.create(:user, role: 'subscriber')
  end

  before do
    seed_completed_tasks

    login_as(subscriber, scope: :user)
  end

  it 'loads completed personal task history in an acceptable time' do
    expect do
      visit subscriber_task_history_path

      expect(page).to have_content('Task History')
      expect(page).to have_content('Completed Task 001')
      expect(page).to have_content('Completed Task 120')
    end.to perform_under(2500).ms
  end

  def seed_completed_tasks
    current_time = Time.current

    IndividualTask.insert_all(
      120.times.map do |index|
        task_number = index + 1

        {
          individual_project_id: subscriber.individual_project.id,
          name: "Completed Task #{task_number.to_s.rjust(3, '0')}",
          description: "Completed performance task #{task_number}",
          due_date: task_number.days.ago,
          reminder_date: nil,
          difficulty: 'easy',
          points: 10,
          read: true,
          status_complete: true,
          created_at: current_time - task_number.days,
          updated_at: current_time - task_number.hours
        }
      end
    )
  end
end
