# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Shared Projects and Workspace', type: :feature do
  describe 'Task Filtering' do
    let!(:subscriber1) { FactoryBot.create(:user, role: 'subscriber', first_name: 'subscriber1', last_name: 'user1') }
    let!(:subscriber2) { FactoryBot.create(:user, role: 'subscriber', first_name: 'subscriber2', last_name: 'user2') }

    before do
      login_as(subscriber1, scope: :user)
    end

    context 'when only my tasks toggle' do
      let!(:project) { FactoryBot.create(:team_project, name: 'Filter Project') }
      let!(:member1) { FactoryBot.create(:team_project_member, user: subscriber1, team_project: project) }

      let!(:task1) do
        FactoryBot.create(:team_project_task, team_project: project, name: 'Task 1', due_date: 1.day.from_now)
      end

      before do
        FactoryBot.create(:team_project_member, user: subscriber2, team_project: project)
        FactoryBot.create(:team_task_assignment, team_project_task: task1, team_project_member: member1)
        FactoryBot.create(:team_project_task, team_project: project, name: 'Task 2', due_date: 1.day.from_now)
        visit subscriber_shared_projects_path
        click_on 'Filter Project'
      end

      specify 'shows only tasks assigned to user when enabled', :js do
        check('assigned_filter')

        within('.task-items') do
          expect(page).to have_content('Task 1')
          expect(page).not_to have_content('Task 2')
        end
      end

      specify 'shows all tasks when disabled' do
        uncheck('assigned_filter')

        within('.task-items') do
          expect(page).to have_content('Task 1')
          expect(page).to have_content('Task 2')
        end
      end

      specify 'works for team lead', :js do
        member1.update(role: 'team_lead')

        visit subscriber_shared_project_path(project)

        check('assigned_filter')

        within('.task-items') do
          expect(page).to have_content('Task 1')
          expect(page).not_to have_content('Task 2')
        end
      end
    end

    context 'when there are edge cases' do
      let!(:project) { FactoryBot.create(:team_project, name: 'Edge Project') }
      let!(:member1) { FactoryBot.create(:team_project_member, user: subscriber1, team_project: project) }

      let!(:task1) do
        FactoryBot.create(:team_project_task, team_project: project, name: 'Task 1', due_date: 1.day.from_now)
      end

      before do
        visit subscriber_shared_projects_path
        click_on 'Edge Project'
      end

      specify 'shows empty state when no assigned tasks exist', :js do
        check('assigned_filter')

        within('.task-items') do
          expect(page).not_to have_css('.task-row')
        end
      end

      specify 'shows all assigned tasks correctly when multiple exist' do
        FactoryBot.create(:team_task_assignment, team_project_task: task1, team_project_member: member1)

        task2 = FactoryBot.create(:team_project_task, team_project: project, name: 'Task 2', due_date: 1.day.from_now)
        FactoryBot.create(:team_task_assignment, team_project_task: task2, team_project_member: member1)

        visit subscriber_shared_project_path(project)

        check('assigned_filter')

        within('.task-items') do
          expect(page).to have_content('Task 1')
          expect(page).to have_content('Task 2')
        end
      end
    end
  end
end
