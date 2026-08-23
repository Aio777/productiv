# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Shared Projects and Workspace', type: :feature do
  let!(:subscriber1) { FactoryBot.create(:user, role: 'subscriber', first_name: 'subscriber1', last_name: 'user1') }
  let!(:subscriber2) { FactoryBot.create(:user, role: 'subscriber', first_name: 'subscriber2', last_name: 'user2') }

  before do
    login_as(subscriber1, scope: :user)
  end

  context 'when task list rendering' do
    specify 'all project tasks are displayed' do
      leading_project = FactoryBot.create(:team_project, name: 'Leading Project')

      FactoryBot.create(:team_project_member, :team_lead, user: subscriber1, team_project: leading_project)
      task1 = FactoryBot.create(:team_project_task, team_project: leading_project, name: 'Task 1',
                                                    due_date: 1.day.from_now)
      task2 = FactoryBot.create(:team_project_task, team_project: leading_project, name: 'Task 2', due_date: 2.day.ago)
      task3 = FactoryBot.create(:team_project_task, team_project: leading_project, name: 'Task 3',
                                                    due_date: 5.days.from_now)

      visit subscriber_shared_projects_path

      expect(page).to have_content('Leading Project')
      click_on 'Leading Project'

      within('.task-items') do
        expect(page).to have_css('.task-row', count: 3)

        within('.task-row', text: 'Task 1') do
          expect(page).to have_css('.task-name', text: 'Task 1')
          expect(page).to have_css('.task-date', text: task1.due_date.strftime('%d %b'))
          expect(page).to have_css("[data-status='pending']")
        end

        within('.task-row', text: 'Task 2') do
          expect(page).to have_css('.task-name', text: 'Task 2')
          expect(page).to have_css('.task-date', text: task2.due_date.strftime('%d %b'))
          expect(page).to have_css("[data-status='delayed']")
        end

        within('.task-row', text: 'Task 3') do
          expect(page).to have_css('.task-name', text: 'Task 3')
          expect(page).to have_css('.task-date', text: task3.due_date.strftime('%d %b'))
          expect(page).to have_css("[data-status='pending']")
        end
      end

      rendered_tasks = all('.task-row .task-name').map(&:text)

      expect(rendered_tasks).to eq(['Task 2', 'Task 1', 'Task 3'])
    end
  end

  context 'when empty and edge states -' do
    specify 'empty state is shown when no tasks exist' do
      leading_project = FactoryBot.create(:team_project, name: 'Leading Project')

      FactoryBot.create(:team_project_member, :team_lead, user: subscriber1, team_project: leading_project)

      visit subscriber_shared_projects_path

      expect(page).to have_content('Leading Project')
      click_on 'Leading Project'

      expect(page).to have_current_path(subscriber_shared_project_path(leading_project))

      within('.task-items') do
        expect(page).not_to have_css('.task-row')
      end
    end

    specify 'large number of tasks renders without breaking layout' do
      leading_project = FactoryBot.create(:team_project, name: 'Leading Project')
      FactoryBot.create(:team_project_member, :team_lead, user: subscriber1, team_project: leading_project)
      member2 = FactoryBot.create(:team_project_member, user: subscriber2, team_project: leading_project)

      tasks = FactoryBot.create_list(:team_project_task, 50, team_project: leading_project)
      tasks.each do |task|
        FactoryBot.create(:team_task_assignment, team_project_task: task, team_project_member: member2)
      end

      visit subscriber_shared_projects_path
      click_on 'Leading Project'

      expect(page).to have_current_path(subscriber_shared_project_path(leading_project))

      expect(page).to have_css('.task-items')
      expect(page).to have_css('.task-row', count: 50)
    end
  end
end
