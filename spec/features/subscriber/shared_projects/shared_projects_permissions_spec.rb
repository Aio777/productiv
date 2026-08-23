# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Shared Projects and Workspace', type: :feature do
  describe 'Permissions' do
    let!(:subscriber1) { FactoryBot.create(:user, role: 'subscriber', first_name: 'subscriber1', last_name: 'user1') }
    let!(:subscriber2) { FactoryBot.create(:user, role: 'subscriber', first_name: 'subscriber2', last_name: 'user2') }

    before do
      login_as(subscriber1, scope: :user)
    end

    context 'when a team member' do
      let!(:member_project) { FactoryBot.create(:team_project, name: 'Member Project') }
      let!(:team_project_membership) do
        FactoryBot.create(:team_project_member, user: subscriber1, team_project: member_project)
      end
      let!(:task1) do
        FactoryBot.create(:team_project_task, team_project: member_project, name: 'Task 1', due_date: 1.day.from_now)
      end

      before do
        FactoryBot.create(:team_project_task, team_project: member_project, name: 'Task 2', due_date: 1.day.from_now)
        visit subscriber_shared_projects_path
        click_on 'Member Project'
      end

      specify 'cannot create or delete tasks' do
        within('.task-list-header') do
          expect(page).not_to have_content('+ Task')
        end

        click_on 'Task 1'
        within('.task-editor') do
          expect(page).not_to have_link('Delete Task')
        end

        click_on 'Task 2'
        within('.task-editor') do
          expect(page).not_to have_link('Delete Task')
        end
      end

      specify 'task fields are disabled' do
        click_on 'Task 1'
        within('.task-editor') do
          expect(page).to have_field('Task name', disabled: true)
          expect(page).to have_field('Description', disabled: true)
          expect(page).to have_field('Due date', disabled: true)
          expect(page).to have_field('Reminder date', disabled: true)
          expect(page).to have_field('Difficulty', disabled: true)
          expect(page).to have_field('Points', disabled: true)
        end

        click_on 'Task 2'
        within('.task-editor') do
          expect(page).to have_field('Task name', disabled: true)
          expect(page).to have_field('Description', disabled: true)
          expect(page).to have_field('Due date', disabled: true)
          expect(page).to have_field('Reminder date', disabled: true)
          expect(page).to have_field('Difficulty', disabled: true)
          expect(page).to have_field('Points', disabled: true)
        end
      end

      specify 'cannot assign team members' do
        FactoryBot.create(:team_task_assignment, team_project_task: task1, team_project_member: team_project_membership)

        click_on 'Task 1'

        within('.assignment-panel') do
          expect(page).not_to have_button('Save Assignments')
          expect(page).to have_css("input[type='checkbox'][disabled]")
        end
      end

      specify 'can view task details', :js do
        click_on 'Task 1'

        within('.task-editor') do
          expect(page).to have_content('Task Details')
          expect(page).to have_field('Task name', with: task1.name, disabled: true)
          expect(page).to have_field('Description', with: task1.description.to_s, disabled: true)
          expect(page).to have_field('Due date', with: task1.due_date.strftime('%Y-%m-%d'), disabled: true)
          expect(page).to have_field('Reminder date', with: task1.reminder_date&.strftime('%Y-%m-%d'), disabled: true)
          expect(page).to have_field('Difficulty', with: task1.difficulty, disabled: true)
          expect(page).to have_field('Points', with: task1.points.to_s, disabled: true)
        end
      end

      specify 'can complete assigned task', :js do
        FactoryBot.create(:team_task_assignment, team_project_task: task1, team_project_member: team_project_membership)

        click_on 'Task 1'

        expect(page).to have_current_path(subscriber_shared_project_path(member_project.id))

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

      specify 'can get the points for completed tasks', :js do
        member2 = FactoryBot.create(:team_project_member, user: subscriber2, team_project: member_project)

        task4 = FactoryBot.create(:team_project_task, team_project: member_project, name: 'Task 4',
                                                      due_date: 1.day.from_now, points: 100)

        FactoryBot.create(:team_task_assignment, team_project_task: task4, team_project_member: team_project_membership)
        FactoryBot.create(:team_task_assignment, team_project_task: task4, team_project_member: member2)

        visit subscriber_shared_project_path(member_project.id)

        click_on 'Task 4'

        expect(page).to have_current_path(subscriber_shared_project_path(member_project.id))

        within('.task-editor') do
          expect(page).to have_button('Complete Task')

          page.execute_script(<<~JS)
            window.confirm = () => true;

            const button = Array.from(document.querySelectorAll('.task-editor button'))
              .find(btn => btn.textContent.trim() === 'Complete Task');

            button.click();
          JS
        end

        expect(page).to have_content('Points: 50')
        expect(subscriber1.reload.points).to eq(50)
        expect(subscriber2.reload.points).to eq(50)
      end
    end

    context 'when a team lead' do
      let!(:lead_project) { FactoryBot.create(:team_project, name: 'Lead Project') }
      let!(:team_project_membership) do
        FactoryBot.create(:team_project_member, :team_lead, user: subscriber1, team_project: lead_project)
      end
      let!(:task1) do
        FactoryBot.create(:team_project_task, team_project: lead_project, name: 'Task 1', due_date: 1.day.from_now)
      end

      before do
        FactoryBot.create(:team_project_member, user: subscriber2, team_project: lead_project)
        FactoryBot.create(:team_project_task, team_project: lead_project, name: 'Task 2', due_date: 1.day.from_now)
        visit subscriber_shared_projects_path
        click_on 'Lead Project'
      end

      specify 'can create and delete tasks' do
        within('.task-list-header') do
          expect(page).to have_content('+ Task')
        end
      end

      specify 'task fields have the correct enabled and disabled states/links' do
        click_on 'Task 1'
        within('.task-editor') do
          expect(page).to have_field('Task name', disabled: false)
          expect(page).to have_field('Description', disabled: false)
          expect(page).to have_field('Due date', disabled: false)
          expect(page).to have_field('Reminder date', disabled: true)
          expect(page).to have_select('Difficulty', disabled: false)
          expect(page).to have_field('Points', disabled: true)
          expect(page).to have_link('Delete Task')
        end
      end

      specify 'can assign and unassign team members' do
        click_on 'Task 1'

        within('.assignment-panel--desktop') do
          expect(page).to have_css("input[type='checkbox']:not([disabled])")
        end

        expect(page).to have_button('Save Task')
      end

      specify 'can complete any task', :js do
        FactoryBot.create(:team_task_assignment, team_project_task: task1, team_project_member: team_project_membership)

        click_on 'Task 1'

        expect(page).to have_current_path(subscriber_shared_project_path(lead_project.id))

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
    end
  end
end
