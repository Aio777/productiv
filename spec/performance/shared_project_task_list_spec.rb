# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Shared project task list performance', type: :feature do
  let!(:subscriber) do
    FactoryBot.create(
      :user,
      role: 'subscriber',
      first_name: 'Performance',
      last_name: 'Tester'
    )
  end

  let!(:team_project) do
    FactoryBot.create(
      :team_project,
      name: 'Performance Shared Project'
    )
  end

  before do
    FactoryBot.create(
      :team_project_member,
      :team_lead,
      user: subscriber,
      team_project: team_project
    )

    seed_shared_tasks

    login_as(subscriber, scope: :user)
  end

  it 'loads the shared project task list in an acceptable time' do
    expect do
      visit subscriber_shared_project_path(team_project)

      expect(page).to have_content('Performance Shared Project')
      expect(page).to have_css('turbo-frame#task_list')
      expect(page).to have_css('.task-items')
      expect(page).to have_css('.task-row', count: 80)

      within('.task-items') do
        expect(page).to have_content('Shared Task 001')
        expect(page).to have_content('Shared Task 080')
      end
    end.to perform_under(2500).ms
  end

  def seed_shared_tasks
    current_time = Time.current

    TeamProjectTask.insert_all(
      80.times.map do |index|
        task_number = index + 1

        {
          team_project_id: team_project.id,
          name: "Shared Task #{task_number.to_s.rjust(3, '0')}",
          description: "Shared performance task #{task_number}",
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
