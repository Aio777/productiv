# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Personal workspace performance', :js, type: :feature do
  let!(:subscriber) do
    FactoryBot.create(:user, role: 'subscriber')
  end

  before do
    seed_pending_tasks

    login_as(subscriber, scope: :user)
  end

  it 'loads the personal workspace page directly in an acceptable time' do
    expect do
      visit subscriber_project_path

      expect(page).to have_current_path(subscriber_project_path)
      expect(page).to have_content('Personal Workspace')
      expect(page).to have_css('turbo-frame#task_list')
      expect(page).to have_css('.task-row', count: 80)
      expect(page).to have_content('Pending Personal Task 001')
      expect(page).to have_content('Pending Personal Task 080')
    end.to perform_under(3000).ms
  end

  it 'navigates from the dashboard to personal workspace through the sidebar in an acceptable time' do
    expect do
      visit subscriber_root_path

      click_link 'Personal Workspace'

      expect(page).to have_current_path(subscriber_project_path)
      expect(page).to have_content('Personal Workspace')
      expect(page).to have_css('turbo-frame#task_list')
      expect(page).to have_css('.task-row', count: 80)
      expect(page).to have_content('Pending Personal Task 001')
      expect(page).to have_content('Pending Personal Task 080')
    end.to perform_under(6000).ms
  end

  def seed_pending_tasks
    current_time = Time.current

    IndividualTask.insert_all(
      80.times.map do |index|
        task_number = index + 1

        {
          individual_project_id: subscriber.individual_project.id,
          name: "Pending Personal Task #{task_number.to_s.rjust(3, '0')}",
          description: "Pending performance task #{task_number}",
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
