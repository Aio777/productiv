# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Shared Projects and Workspace', type: :feature do
  describe 'Task Creation' do
    let!(:subscriber1) { FactoryBot.create(:user, role: 'subscriber', first_name: 'subscriber1', last_name: 'user1') }
    let!(:project) { FactoryBot.create(:team_project, name: 'Creation Project') }

    before do
      FactoryBot.create(:team_project_member, :team_lead, user: subscriber1, team_project: project)
      login_as(subscriber1, scope: :user)
      visit subscriber_shared_project_path(project)
    end

    context 'when a team lead' do
      specify 'can open new task form', :js do
        click_on '+ Task'

        within('turbo-frame#task_detail') do
          expect(page).to have_content('Task Details')
          expect(page).to have_field('Task name')
          expect(page).to have_field('Description')
          expect(page).to have_field('Due date')
          expect(page).to have_field('Reminder date', disabled: true)
          expect(page).to have_select('Difficulty')
          expect(page).not_to have_field('Points')
          expect(page).to have_button('Create Task')
        end
      end
    end

    context 'when creation is successful' do
      specify 'creates task, shows it in the list and allows selection', :js do
        click_on '+ Task'

        within('turbo-frame#task_detail') do
          fill_in 'Task name', with: 'New Task'
          fill_in 'Description', with: 'Test description'
          fill_in 'Due date', with: 1.day.from_now.strftime('%Y-%m-%d')
          select 'Medium', from: 'Difficulty'

          click_button 'Create Task'
        end

        task = TeamProjectTask.last

        expect(page).to have_current_path(subscriber_shared_project_path(project, task_id: task.id))
        expect(page).to have_content('New Task')

        within('.task-items') do
          expect(page).to have_content('New Task')
          click_on 'New Task'
        end

        within('.task-editor') do
          expect(page).to have_field('Task name', with: 'New Task')
          expect(page).to have_field('Description', with: 'Test description')
        end
      end
    end
  end

  describe 'Task Editing' do
    let!(:subscriber1) { FactoryBot.create(:user, role: 'subscriber', first_name: 'subscriber1', last_name: 'user1') }
    let!(:project) { FactoryBot.create(:team_project, name: 'Edit Project') }

    let!(:task1) do
      FactoryBot.create(:team_project_task,
                        team_project: project,
                        name: 'Original Task',
                        description: 'Original description',
                        due_date: 1.day.from_now,
                        difficulty: 'easy',
                        points: 10)
    end

    before do
      FactoryBot.create(:team_project_member, :team_lead, user: subscriber1, team_project: project)
      login_as(subscriber1, scope: :user)
      visit subscriber_shared_project_path(project)
      click_on 'Original Task'
    end

    context 'when a team lead' do
      specify 'updates task field and changes persist after refresh' do
        within('.task-editor') do
          fill_in 'Task name', with: 'Updated Task'
          fill_in 'Description', with: 'Updated description'
          fill_in 'Due date', with: 2.days.from_now.strftime('%Y-%m-%d')
          select 'Medium', from: 'Difficulty'

          click_button 'Save Task'
        end

        expect(page).to have_content('Task updated.')
        expect(page).to have_content('Updated Task')

        task1.reload

        expect(task1.name).to eq('Updated Task')
        expect(task1.description).to eq('Updated description')
        expect(task1.difficulty).to eq('medium')

        visit current_path

        click_on 'Updated Task'

        within('.task-editor') do
          expect(page).to have_field('Task name', with: 'Updated Task')
          expect(page).to have_field('Description', with: 'Updated description')
        end
      end
    end

    context 'when validation' do
      specify 'rejects invalid updates and prerves existing task data', :js do
        within('.task-editor') do
          fill_in 'Task name', with: ''
          click_button 'Save Task'
        end

        expect(page).to have_current_path(subscriber_shared_project_path(project))
        expect(task1.reload.name).to eq('Original Task')
        expect(task1.description).to eq('Original description')
        expect(task1.difficulty).to eq('easy')
        expect(task1.points).to eq(10)
      end
    end
  end

  describe 'Task Deletion', :js do
    let!(:subscriber1) { FactoryBot.create(:user, role: 'subscriber', first_name: 'subscriber1', last_name: 'user1') }
    let!(:project) { FactoryBot.create(:team_project, name: 'Deletion Project') }

    before do
      FactoryBot.create(:team_project_member, :team_lead, user: subscriber1, team_project: project)
      FactoryBot.create(:team_project_task, team_project: project, name: 'Delete Me', due_date: 1.day.from_now,
                                            difficulty: 'easy', points: 10)
      login_as(subscriber1, scope: :user)
      visit subscriber_shared_project_path(project)
      click_on 'Delete Me'
    end

    context 'when a team lead' do
      specify 'removes task from list' do
        expect(page).to have_current_path(subscriber_shared_project_path(project))
        within('.task-editor') do
          expect(page).to have_link('Delete Task')

          page.execute_script(<<~JS)
            window.confirm = () => true;

            const link = Array.from(document.querySelectorAll('.task-editor a'))
              .find(a => a.textContent.trim() === 'Delete Task');

            link.click();
          JS
        end

        expect(page).to have_current_path(subscriber_shared_project_path(project))

        within('.task-items') do
          expect(page).to have_no_content('Delete Me')
        end
      end
    end
  end
end
