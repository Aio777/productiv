# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Shared Projects and Workspace', type: :feature do
  describe 'Shared Projects Navigation' do
    let!(:subscriber1) { FactoryBot.create(:user, role: 'subscriber', first_name: 'subscriber1', last_name: 'user1') }
    let!(:subscriber2) { FactoryBot.create(:user, role: 'subscriber', first_name: 'subscriber2', last_name: 'user2') }

    before do
      login_as(subscriber1, scope: :user)
    end

    context 'when visibility and access' do
      specify 'user sees only projects they belong to' do
        visible_project = FactoryBot.create(:team_project, name: 'Visible Project')
        hidden_project = FactoryBot.create(:team_project, name: 'Hidden Project')

        FactoryBot.create(:team_project_member, user: subscriber1, team_project: visible_project, role: 'team_member')
        FactoryBot.create(:team_project_member, user: subscriber2, team_project: hidden_project, role: 'team_member')

        visit subscriber_shared_projects_path

        expect(page).to have_content('Visible Project')
        expect(page).not_to have_content('Hidden Project')
      end

      specify 'team lead sees projects they lead and are members of', :js do
        leading_project = FactoryBot.create(:team_project, name: 'Leading Project')
        member_project = FactoryBot.create(:team_project, name: 'Member Project')

        FactoryBot.create(:team_project_member, :team_lead, user: subscriber1, team_project: leading_project)
        FactoryBot.create(:team_project_member, user: subscriber1, team_project: member_project)

        visit subscriber_shared_projects_path

        expect(page).to have_content('Leading Project')
        expect(page).to have_content('Member Project')
      end

      specify 'team member sees only assigned projects' do
        assigned_project = FactoryBot.create(:team_project, name: 'Assigned Project')
        unassigned_project = FactoryBot.create(:team_project, name: 'Unassigned Project')

        FactoryBot.create(:team_project_member, user: subscriber1, team_project: assigned_project, role: 'team_member')
        FactoryBot.create(:team_project_member, user: subscriber2, team_project: unassigned_project,
                                                role: 'team_member')

        visit subscriber_shared_projects_path

        expect(page).to have_content('Assigned Project')
        expect(page).not_to have_content('Unassigned Project')
      end

      specify 'user sees empty state when no projects exist' do
        visit subscriber_shared_projects_path
        expect(page).not_to have_css('.project-card')
      end

      specify 'projects list loads successfully with correct percentages', :js do
        leading_project = FactoryBot.create(:team_project, name: 'Leading Project')
        member_project1 = FactoryBot.create(:team_project, name: 'Member Project1')
        member_project2 = FactoryBot.create(:team_project, name: 'Member Project2')

        FactoryBot.create(:team_project_member, :team_lead, user: subscriber1, team_project: leading_project)
        FactoryBot.create(:team_project_member, user: subscriber1, team_project: member_project1)
        FactoryBot.create(:team_project_member, user: subscriber1, team_project: member_project2)

        FactoryBot.create(:team_project_task, team_project: leading_project, name: 'Task 1', due_date: 1.day.from_now)
        FactoryBot.create(:team_project_task, team_project: leading_project, name: 'Task 2', due_date: 1.day.from_now,
                                              status_complete: true)

        visit subscriber_shared_projects_path

        expect(page).to have_content('Leading Project - 50%')
        expect(page).to have_content('Member Project1 - 0%')
        expect(page).to have_content('Member Project2 - 0%')
      end
    end

    context 'when navigation' do
      specify 'clicking a project opens the correct workspace', :js do
        leading_project = FactoryBot.create(:team_project, name: 'Leading Project')
        member_project1 = FactoryBot.create(:team_project, name: 'Member Project1')

        FactoryBot.create(:team_project_member, :team_lead, user: subscriber1, team_project: leading_project)
        FactoryBot.create(:team_project_member, user: subscriber1, team_project: member_project1)

        visit subscriber_shared_projects_path

        expect(page).to have_content('Leading Project')
        click_on 'Leading Project'
        expect(page).to have_current_path(subscriber_shared_project_path(leading_project.id))
      end

      specify 'from project leaderbaord can navigate to project tasks via Task button as a team lead' do
        leading_project = FactoryBot.create(:team_project, name: 'Leading Project')
        FactoryBot.create(:team_project_member, :team_lead, user: subscriber1, team_project: leading_project)

        visit subscriber_shared_project_leaderboard_path(leading_project)
        expect(page).to have_link('Tasks')
        click_on 'Tasks'
        expect(page).to have_current_path(subscriber_shared_project_path(leading_project))
      end

      specify 'from project setting can navigate to project tasks via Task button as a team lead' do
        leading_project = FactoryBot.create(:team_project, name: 'Leading Project')
        FactoryBot.create(:team_project_member, :team_lead, user: subscriber1, team_project: leading_project)

        visit edit_subscriber_shared_project_path(leading_project)
        expect(page).to have_link('Tasks')
        click_on 'Tasks'
        expect(page).to have_current_path(subscriber_shared_project_path(leading_project))
      end

      specify 'from project leaderbaord can navigate to project tasks via Task button as a team member' do
        project = FactoryBot.create(:team_project, name: 'Project')
        FactoryBot.create(:team_project_member, user: subscriber1, team_project: project)

        visit subscriber_shared_project_leaderboard_path(project)
        expect(page).to have_link('Tasks')
        click_on 'Tasks'
        expect(page).to have_current_path(subscriber_shared_project_path(project))
      end

      specify 'from project setting can navigate to project tasks via Task button as a team member' do
        project = FactoryBot.create(:team_project, name: 'Project')
        FactoryBot.create(:team_project_member, user: subscriber1, team_project: project)
        FactoryBot.create(:team_project_member, :team_lead, user: subscriber2, team_project: project)

        visit subscriber_shared_project_settings_path(project)
        expect(page).to have_link('Tasks')
        click_on 'Tasks'
        expect(page).to have_current_path(subscriber_shared_project_path(project))
      end

      specify 'user is blocked from accessing project via url if unauthorized' do
        unauthorized_project = create(:team_project, name: 'Secret Project')
        FactoryBot.create(:team_project_member, user: subscriber2, team_project: unauthorized_project)

        visit subscriber_shared_project_path(unauthorized_project)

        expect(page).to have_content('Action Forbidden')
      end
    end
  end
end
