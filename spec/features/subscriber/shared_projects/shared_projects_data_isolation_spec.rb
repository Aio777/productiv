# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Shared Projects', type: :feature do
  describe 'Data Isolation' do
    let!(:subscriber1) { FactoryBot.create(:user, role: 'subscriber', first_name: 'subscriber1', last_name: 'user1') }
    let!(:subscriber2) { FactoryBot.create(:user, role: 'subscriber', first_name: 'subscriber2', last_name: 'user2') }

    let!(:project1) { FactoryBot.create(:team_project, name: 'Project 1') }
    let!(:project2) { FactoryBot.create(:team_project, name: 'Project 2') }

    let!(:member1_p1) { FactoryBot.create(:team_project_member, :team_lead, user: subscriber1, team_project: project1) }

    let!(:task_p1) do
      FactoryBot.create(:team_project_task,
                        team_project: project1,
                        name: 'Task P1',
                        due_date: 1.day.from_now,
                        difficulty: 'easy',
                        points: 10)
    end

    let!(:task_p2) do
      FactoryBot.create(:team_project_task,
                        team_project: project2,
                        name: 'Task P2',
                        due_date: 1.day.from_now,
                        difficulty: 'easy',
                        points: 10)
    end

    before do
      FactoryBot.create(:team_project_member, user: subscriber2, team_project: project2)
      login_as(subscriber1, scope: :user)
      visit subscriber_shared_projects_path
      click_on 'Project 1'
    end

    specify 'tasks from one project do not appear in another' do
      within('.task-items') do
        expect(page).to have_content('Task P1')
        expect(page).not_to have_content('Task P2')
      end
    end

    specify 'task assignments are scoped to correct project' do
      FactoryBot.create(:team_task_assignment, team_project_task: task_p1, team_project_member: member1_p1)

      expect(task_p1.reload.assigned_members).to include(member1_p1)
      expect(task_p2.reload.assigned_members).to be_empty
    end

    specify 'user only sees members of current project' do
      visit subscriber_shared_project_path(project1)
      click_on 'Task P1'

      within('.assignment-panel') do
        expect(page).to have_content(subscriber1.first_name)
        expect(page).not_to have_content(subscriber2.first_name)
      end
    end
  end
end
