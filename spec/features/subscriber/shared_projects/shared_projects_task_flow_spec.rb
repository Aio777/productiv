# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Shared Projects and Workspace', type: :feature do
  describe 'Task Assignment' do
    let!(:subscriber1) { FactoryBot.create(:user, role: 'subscriber', first_name: 'subscriber1', last_name: 'user1') }
    let!(:subscriber2) { FactoryBot.create(:user, role: 'subscriber', first_name: 'subscriber2', last_name: 'user2') }
    let!(:subscriber3) { FactoryBot.create(:user, role: 'subscriber', first_name: 'subscriber3', last_name: 'user3') }

    let!(:project) { FactoryBot.create(:team_project, name: 'Assignment Project') }
    let!(:team_lead_membership) do
      FactoryBot.create(:team_project_member, :team_lead, user: subscriber1, team_project: project)
    end
    let!(:member2) { FactoryBot.create(:team_project_member, user: subscriber2, team_project: project) }

    let!(:task1) do
      create(:team_project_task,
             team_project: project,
             name: 'Task 1',
             due_date: 1.day.from_now,
             difficulty: 'easy',
             points: 10)
    end

    before do
      login_as(subscriber1, scope: :user)
      visit subscriber_shared_project_path(project)
      click_on 'Task 1'
    end

    context 'when a team lead' do
      specify 'shows only project members in assignment list' do
        within('.assignment-panel') do
          expect(page).to have_content(subscriber1.first_name)
          expect(page).to have_content(subscriber2.first_name)
          expect(page).not_to have_content(subscriber3.first_name)
        end
      end

      specify 'can assign, unassign and assign multiple members to a task' do
        all("input[type='checkbox'][value='#{member2.id}']", visible: :all).each(&:check)
        click_button 'Save Task'

        expect(task1.reload.assigned_members.map(&:user)).to include(subscriber2)

        click_on 'Task 1'

        all("input[type='checkbox'][value='#{member2.id}']", visible: :all).each(&:uncheck)
        click_button 'Save Task'

        expect(task1.reload.assigned_members).to be_empty

        member3 = FactoryBot.create(:team_project_member, user: subscriber3, team_project: project)

        click_on 'Task 1'

        [team_lead_membership, member2, member3].each do |member|
          all("input[type='checkbox'][value='#{member.id}']", visible: :all).each(&:check)
        end

        click_button 'Save Task'

        assigned_users = task1.reload.assigned_members.map(&:user)

        expect(assigned_users).to contain_exactly(subscriber1, subscriber2, subscriber3)
      end
    end
  end

  describe 'Task Completion' do
    let!(:subscriber1) { FactoryBot.create(:user, role: 'subscriber', first_name: 'subscriber1', last_name: 'user1') }
    let!(:subscriber2) { FactoryBot.create(:user, role: 'subscriber', first_name: 'subscriber2', last_name: 'user2') }
    let!(:random_lead) { FactoryBot.create(:user, role: 'subscriber', first_name: 'teamlead', last_name: 'lead') }

    let!(:project) { FactoryBot.create(:team_project, name: 'Completion Project') }
    let!(:member1) { FactoryBot.create(:team_project_member, user: subscriber1, team_project: project) }
    let!(:member2) { FactoryBot.create(:team_project_member, user: subscriber2, team_project: project) }
    let!(:member_lead) { FactoryBot.create(:team_project_member, :team_lead, user: random_lead, team_project: project) }

    let!(:task1) do
      FactoryBot.create(:team_project_task,
                        team_project: project,
                        name: 'Task 1',
                        due_date: 1.day.from_now,
                        difficulty: 'easy',
                        points: 100)
    end

    before do
      login_as(subscriber1, scope: :user)
      visit subscriber_shared_project_path(project)
    end

    context 'when a team member' do
      specify 'can complete assigned task', :js do
        FactoryBot.create(:team_task_assignment, team_project_task: task1, team_project_member: member1)

        click_on 'Task 1'

        expect(page).to have_current_path(subscriber_shared_project_path(project))

        within('.task-editor') do
          expect(page).to have_button('Complete Task')

          page.execute_script(<<~JS)
            window.confirm = () => true;

            const button = Array.from(document.querySelectorAll('.task-editor button'))
              .find(btn => btn.textContent.trim() === 'Complete Task');

            button.click();
          JS
        end

        expect(page).to have_content('Task marked as complete')

        within('.task-items') do
          expect(page).to have_no_content('Task 1')
        end
      end

      specify 'cannot complete unassigned task' do
        FactoryBot.create(:team_task_assignment, team_project_task: task1, team_project_member: member2)

        expect(page).to have_current_path(subscriber_shared_project_path(project))

        click_on 'Task 1'

        within('.task-editor') do
          expect(page).not_to have_button('Complete Task')
        end
      end
    end

    context 'when a team lead' do
      specify 'can complete any task', :js do
        logout(:user)
        login_as(random_lead, scope: :user)
        visit subscriber_shared_project_path(project)
        FactoryBot.create(:team_task_assignment, team_project_task: task1, team_project_member: member2)

        click_on 'Task 1'

        expect(page).to have_current_path(subscriber_shared_project_path(project))

        # expect(page).to have_content('0% Complete')

        within('.task-editor') do
          expect(page).to have_button('Complete Task')

          page.execute_script(<<~JS)
            window.confirm = () => true;

            const button = Array.from(document.querySelectorAll('.task-editor button'))
            .find(btn => btn.textContent.trim() === 'Complete Task');

            button.click();
          JS
        end

        expect(page).to have_content('Task marked as complete')

        # expect(page).to have_content('100% Complete')

        within('.task-items') do
          expect(page).to have_no_content('Task 1')
        end
      end
    end

    context 'when looking at effects' do
      specify 'points update correctly', :js do
        logout(:user)
        login_as(random_lead, scope: :user)
        visit subscriber_shared_project_path(project)
        FactoryBot.create(:team_task_assignment, team_project_task: task1, team_project_member: member_lead)
        FactoryBot.create(:team_task_assignment, team_project_task: task1, team_project_member: member2)

        click_on 'Task 1'

        expect(page).to have_current_path(subscriber_shared_project_path(project))

        within('.task-editor') do
          expect(page).to have_button('Complete Task')

          page.execute_script(<<~JS)
            window.confirm = () => true;

            const button = Array.from(document.querySelectorAll('.task-editor button'))
              .find(btn => btn.textContent.trim() === 'Complete Task');

            button.click();
          JS
        end

        expect(page).to have_current_path(subscriber_shared_project_path(project))

        expect(task1.reload.status_complete).to be(true)

        within('.task-items') do
          expect(page).to have_no_content('Task 1')
        end

        expect(random_lead.reload.points).to eq(50)
        expect(subscriber2.reload.points).to eq(50)
      end
    end
  end
end
