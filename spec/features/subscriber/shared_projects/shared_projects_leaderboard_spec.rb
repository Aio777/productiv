# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Shared Projects and Workspace', type: :feature do
  describe 'Leaderboard' do
    let!(:subscriber1) { FactoryBot.create(:user, role: 'subscriber', first_name: 'subscriber1', last_name: 'user1') }
    let!(:subscriber2) { FactoryBot.create(:user, role: 'subscriber', first_name: 'subscriber2', last_name: 'user2') }
    let!(:subscriber3) { FactoryBot.create(:user, role: 'subscriber', first_name: 'subscriber3', last_name: 'user3') }

    let!(:project) { FactoryBot.create(:team_project, name: 'Leaderboard Project', leaderboard_visible: true) }

    let!(:project_off) { FactoryBot.create(:team_project, name: 'Leaderboard Off Project', leaderboard_visible: false) }

    before do
      FactoryBot.create(:team_project_member, :team_lead, user: subscriber1, team_project: project, points: 100)
      FactoryBot.create(:team_project_member, user: subscriber2, team_project: project, points: 50)
      FactoryBot.create(:team_project_member, user: subscriber3, team_project: project, points: 75,
                                              leaderboard_visibility: false)
      FactoryBot.create(:team_project_member, :team_lead, user: subscriber1, team_project: project_off, points: 100)
      FactoryBot.create(:team_project_member, user: subscriber2, team_project: project_off, points: 50)
    end

    context 'when leaderboard is visible' do
      specify 'team lead can view the project leaderboard', :js do
        login_as(subscriber1, scope: :user)

        visit subscriber_shared_projects_path
        click_on 'Leaderboard Project'

        within('.subscriber-top-navbar') do
          click_on 'Leaderboard'
        end

        expect(page).to have_content('Team Leaderboard')
        expect(page).to have_content('subscriber1 user1')
        expect(page).to have_content('subscriber2 user2')
      end

      specify 'team member can view leaderboard when visible' do
        login_as(subscriber2, scope: :user)

        visit subscriber_shared_project_leaderboard_path(project)

        expect(page).to have_content('Team Leaderboard')
        expect(page).to have_content('subscriber1 user1')
        expect(page).to have_content('subscriber2 user2')
      end

      specify 'TM can view leaderboard when visible in desc order & their correct points' do
        login_as(subscriber2, scope: :user)

        visit subscriber_shared_project_leaderboard_path(project)

        expect(page).to have_content('Team Leaderboard')

        rows = all('.leaderboard-row .leaderboard-cell--name').map(&:text)

        within('tr', text: 'subscriber1 user1') do
          expect(page).to have_content('100')
        end
        within('tr', text: 'subscriber2 user2') do
          expect(page).to have_content('50')
        end

        expect(rows.first).to include('subscriber1 user1')
        expect(rows.second).to include('subscriber2 user2')
      end

      specify 'Team Member opts out of being in the leaderboard' do
        login_as(subscriber2, scope: :user)

        visit subscriber_shared_project_settings_path(project)

        check 'Opt out of Leaderboard'

        click_on 'Save Settings'

        visit subscriber_shared_project_leaderboard_path(project)

        expect(page).not_to have_content('subscriber2 user2')
      end

      specify 'Team Member opts in of being in the leaderboard' do
        login_as(subscriber3, scope: :user)

        visit subscriber_shared_project_settings_path(project)

        uncheck 'Opt out of Leaderboard'

        click_on 'Save Settings'

        visit subscriber_shared_project_leaderboard_path(project)

        expect(page).to have_content('subscriber3 user3')
      end
    end

    context 'when leaderboard is hidden' do
      specify 'team lead can toggle leaderboard off' do
        login_as(subscriber1, scope: :user)

        visit edit_subscriber_shared_project_path(project)

        check('Hide Leaderboard for all Members')
        click_button 'Update Project'

        expect(page).to have_current_path(edit_subscriber_shared_project_path(project))

        within('.subscriber-top-navbar') do
          expect(page).not_to have_link('Leaderboard')
        end
      end

      specify 'team lead can toggle leaderboard on' do
        login_as(subscriber1, scope: :user)

        visit edit_subscriber_shared_project_path(project_off)

        uncheck('Hide Leaderboard for all Members')
        click_button 'Update Project'

        expect(page).to have_current_path(edit_subscriber_shared_project_path(project_off))

        within('.subscriber-top-navbar') do
          expect(page).to have_link('Leaderboard')
        end
      end

      specify 'redirects team lead if leaderboard is hidden and they try to access it via URL' do
        login_as(subscriber1, scope: :user)

        visit subscriber_shared_project_leaderboard_path(project_off)

        expect(page).to have_current_path(subscriber_shared_project_path(project_off))
      end

      specify 'redirects team member if leaderboard is hidden and they try to access it via URL' do
        login_as(subscriber2, scope: :user)

        visit subscriber_shared_project_leaderboard_path(project_off)

        expect(page).to have_current_path(subscriber_shared_project_path(project_off))
      end
    end
  end
end
