# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Personal task list performance', type: :feature do
  let!(:subscriber) do
    FactoryBot.create(
      :user,
      role: 'subscriber',
      first_name: 'Performance',
      last_name: 'Tester'
    )
  end

  before do
    seed_personal_tasks

    login_as(subscriber, scope: :user)
  end

  it 'loads the personal workspace task list in an acceptable time' do
    expect do
      visit subscriber_project_path

      expect(page).to have_text('Personal Workspace')
      expect(page).to have_css('turbo-frame#task_list')
      expect(page).to have_css('.task-items')
      expect(page).to have_css('.task-row', count: 80)

      within('.task-items') do
        expect(page).to have_content('Personal Task 001')
        expect(page).to have_content('Personal Task 080')
      end
    end.to perform_under(2500).ms
  end

  def seed_personal_tasks
    current_time = Time.current

    IndividualTask.insert_all(
      80.times.map do |index|
        task_number = index + 1

        {
          individual_project_id: subscriber.individual_project.id,
          name: "Personal Task #{task_number.to_s.rjust(3, '0')}",
          description: "Performance task #{task_number}",
          due_date: (task_number - 20).days.from_now,
          reminder_date: nil,
          difficulty: 'easy',
          points: 10,
          read: false,
          status_complete: false,
          created_at: current_time,
          updated_at: current_time
        }
      end
    )
  end
end
