# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Subscriber manages their personal workspace', type: :feature do
  let!(:subscriber) { FactoryBot.create(:user, role: 'subscriber', first_name: 'subscriber', last_name: 'user') }

  before do
    login_as(subscriber, scope: :user)
  end

  it 'views their workspace' do
    FactoryBot.create(:individual_task, name: 'Task 1', individual_project: subscriber.individual_project,
                                        due_date: 1.day.from_now)
    visit subscriber_project_path
    expect(page).to have_text('Personal Workspace')
    expect(page).to have_css('turbo-frame#task_list')
    expect(page).to have_text('Task 1')
  end

  it 'selects a task from the task list' do
    task = FactoryBot.create(:individual_task, name: 'Task 1', individual_project: subscriber.individual_project,
                                               due_date: 1.day.from_now)
    visit subscriber_project_path
    expect(page).to have_text('Task 1')

    click_on 'Task 1'
    expect(page).to have_text('Task Details')
    expect(page).to have_field('Due date', with: task.due_date.strftime('%Y-%m-%d'))
    expect(page).to have_field('Task name', with: task.name)
    expect(page).to have_field('Description', with: task.description)
    expect(page).to have_field('Task name', with: task.name)
    expect(page).to have_field('Description', with: task.description)
  end

  it 'creates a new task', :js do
    visit subscriber_project_path
    click_on '+ Task'

    expect(page).to have_text('Task Details')

    fill_in 'Task name', with: 'New Task'
    fill_in 'Description', with: 'New Task description'
    fill_in 'Due date', with: 1.day.from_now
    select 'Medium', from: 'Difficulty'

    click_on 'Create Task'

    expect(page).to have_text('New Task')

    click_on 'New Task'
    expect(page).to have_field('Task name', with: 'New Task')
  end

  it 'delete a task', :js do
    FactoryBot.create(:individual_task, name: 'Task 1', individual_project: subscriber.individual_project,
                                        due_date: 1.day.from_now)
    visit subscriber_project_path

    expect(page).to have_text('Task 1')

    click_on 'Task 1'

    expect(page).to have_current_path(subscriber_project_path)

    page.execute_script(<<~JS)
      window.confirm = () => true;

      const link = Array.from(document.querySelectorAll('a'))
        .find(a => a.textContent.trim() === 'Delete Task');

      link.click();
    JS

    expect(page).not_to have_text('Task 1')
  end

  it 'completes a task and the points are updated to reflect the completion', :js do
    FactoryBot.create(:individual_task, name: 'Task 1', individual_project: subscriber.individual_project,
                                        due_date: 1.day.from_now)
    visit subscriber_project_path

    expect(page).to have_text('Task 1')

    click_on 'Task 1'

    expect(page).to have_current_path(subscriber_project_path)

    page.execute_script(<<~JS)
      window.confirm = () => true;

      const button = Array.from(document.querySelectorAll('button'))
        .find(btn => btn.textContent.trim() === 'Complete Task');

      button.click();
    JS

    expect(page).not_to have_text('Task 1')
  end

  it 'edits a task' do
    task = FactoryBot.create(:individual_task, name: 'Task 1', individual_project: subscriber.individual_project,
                                               due_date: 1.day.from_now)
    visit subscriber_project_path

    click_on 'Task 1'

    expect(page).to have_text('Task Details')
    expect(page).to have_field('Due date', with: task.due_date.strftime('%Y-%m-%d'))
    expect(page).to have_field('Task name', with: task.name)
    expect(page).to have_field('Description', with: task.description)
    expect(page).to have_field('Task name', with: task.name)
    expect(page).to have_field('Description', with: task.description)

    fill_in 'Task name', with: 'Updated Task Name'

    click_on 'Save Task'
    expect(page).to have_text('Updated Task Name')

    click_on 'Updated Task Name'
    expect(page).to have_field('Task name', with: 'Updated Task Name')
  end

  it 'allows you to set reminder (toggle on)' do
    task = FactoryBot.create(:individual_task, name: 'Task 1', individual_project: subscriber.individual_project,
                                               reminder_date: 1.day.from_now, due_date: 2.day.from_now)
    visit subscriber_project_path

    click_on task.name

    expect(page).to have_checked_field('reminder_enabled')
    expect(page).to have_field('Reminder date', with: task.reminder_date.strftime('%Y-%m-%d'))
    fill_in 'Reminder date', with: 2.days.from_now

    click_on 'Save Task'

    click_on task.name
    expect(page).to have_field('Reminder date', with: 2.days.from_now.strftime('%Y-%m-%d'))
  end

  it 'allows you to not set reminder (toggle off)' do
    task = FactoryBot.create(:individual_task, name: 'Task 1', individual_project: subscriber.individual_project,
                                               reminder_date: 1.day.from_now, due_date: 2.day.from_now)
    visit subscriber_project_path

    click_on task.name

    expect(page).to have_checked_field('reminder_enabled')
    uncheck 'reminder_enabled'
    click_on 'Save Task'
    click_on task.name

    expect(page).not_to have_field('Reminder date', with: task.reminder_date.strftime('%Y-%m-%d'))
    expect(page).to have_unchecked_field('reminder_enabled')
    expect(page).to have_field('Reminder date', disabled: true)
    task.reload
    expect(task.reminder_date).to be_nil
  end

  it 'shows pending image for tasks with due date beyond current date' do
    FactoryBot.create(:individual_task, name: 'Task 1', individual_project: subscriber.individual_project,
                                        due_date: 1.day.from_now)
    visit subscriber_project_path

    expect(page).to have_css("[data-status='pending']")
  end

  it 'shows pending image for tasks with due date before current date' do
    FactoryBot.create(:individual_task, name: 'Task 1', individual_project: subscriber.individual_project,
                                        due_date: 1.day.ago)
    visit subscriber_project_path

    expect(page).to have_css("[data-status='delayed']")
  end

  it 'redirects reporter to home when not subscriber' do
    reporter = FactoryBot.create(:user, role: 'reporter')
    login_as reporter, scope: :user
    visit subscriber_project_path
    expect(page).not_to have_current_path(subscriber_project_path)
    expect(page).to have_content('Logout')
  end

  it 'redirects admin to home when not subscriber' do
    admin = FactoryBot.create(:user, role: 'admin')
    login_as admin, scope: :user
    visit subscriber_project_path
    expect(page).not_to have_current_path(subscriber_project_path)
    expect(page).to have_content('Logout')
  end

  it 'redirects signee to home when not subscriber' do
    signee = FactoryBot.create(:user, role: 'signee')
    login_as signee, scope: :user
    visit subscriber_project_path
    expect(page).not_to have_current_path(subscriber_project_path)
    expect(page).to have_content('Logout')
  end

  it 'redirects non user to home when not subscriber' do
    logout
    visit subscriber_project_path
    expect(page).not_to have_current_path(subscriber_project_path)
    expect(page).to have_content('Log In')
  end
end
