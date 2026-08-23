# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Notification reminders', :js, type: :feature do
  let!(:subscriber) { FactoryBot.create(:user, role: 'subscriber', first_name: 'subscriber', last_name: 'user') }

  let!(:individual_task1) do
    FactoryBot.create(:individual_task, name: 'Write some tests', individual_project: subscriber.individual_project,
                                        reminder_date: 1.week.ago)
  end
  let!(:individual_task2) do
    FactoryBot.create(:individual_task, name: 'Write some documentation',
                                        individual_project: subscriber.individual_project, reminder_date: 2.week.ago)
  end

  before do
    FactoryBot.create(:notification, individual_task: individual_task1, user: subscriber,
                                     message: individual_task1.name, read: false)
    FactoryBot.create(:notification, individual_task: individual_task2, user: subscriber,
                                     message: individual_task2.name, read: true)
    login_as(subscriber, scope: :user)
    visit "#{subscriber_notifications_path}?tab=reminders"
  end

  describe 'Notification Page' do
    context 'when the Reminder tab is selected' do
      specify 'user sees reminder notifications by default and switches to invites' do
        expect(page).to have_button('Mark as Read')
        click_link 'Shared Invites'
        expect(page).to have_content('No shared project invitations at the moment.')
      end

      specify 'user can mark a notification as read' do
        click_button 'Mark as Read'
        expect(page).to have_button('Mark as Unread')
        expect(page).not_to have_button('Mark as Read')
      end

      specify 'user can click on a notification and it will take them to the exact task - individual project', :js do
        within('.notification-task-row', text: 'Write some tests') do
          click_link 'Go To Task'
        end

        expect(page).to have_current_path(subscriber_project_path(task_id: individual_task1.id))

        expect(page).to have_field('Task name', with: individual_task1.name)
      end

      specify 'user can click on a notification and it will take them to the exact task - shared project', :js do
        project = FactoryBot.create(:team_project)
        team_task = FactoryBot.create(:team_project_task, name: 'Team Sprint Review', team_project: project,
                                                          reminder_date: 1.day.ago)
        member = FactoryBot.create(:team_project_member, user: subscriber, team_project: project)
        FactoryBot.create(:team_task_assignment, team_project_task: team_task, team_project_member: member)
        FactoryBot.create(:notification, :with_team_task, user: subscriber, team_project_task: team_task,
                                                          message: team_task.name, read: false)

        click_link 'Team Reminders'

        within('.notification-task-row', text: 'Team Sprint Review') do
          click_link 'Go To Task'
        end

        expect(page).to have_current_path(subscriber_shared_project_path(project, task_id: team_task.id))

        expect(page).to have_field('Task name', with: team_task.name, disabled: :all)
      end
    end

    context 'when the Inbox is Empty' do
      specify 'The Empty Inbox message is removed when user marks the notification as read and then unread' do
        click_button 'Mark as Read'
        expect(page).to have_content('No new notifications')
        expect(page).to have_content("You're all caught up!")
        click_button 'Mark as Unread'
        expect(page).not_to have_content('No new notifications')
        expect(page).not_to have_content("You're all caught up!")
      end
    end
  end

  describe 'Filtering Logic' do
    before { click_link 'Reminders' }

    specify 'read notifications are hidden by default' do
      expect(page).to have_content('Mark as Read')
      expect(page).to have_css("[data-read='false']")
      expect(page).to have_css("[data-read='true']", visible: false)
    end

    specify 'shows all notifications when "Show all" is toggled' do
      find('.form-check-input').set(true)

      expect(page).to have_content('Mark as Read')
      expect(page).to have_content('Mark as Unread')
      expect(page).to have_css("[data-read='true']", visible: true)
    end
  end

  describe 'Notification badge' do
    specify 'The badge does not appear when there are no reminders' do
      within 'aside.subscriber-side-navbar' do
        expect(page).to have_link('Notifications')
        expect(page).to have_css('.badge', text: 1)
      end
      click_button 'Mark as Read'
      within 'aside.subscriber-side-navbar' do
        expect(page).to have_link('Notifications')
        expect(page).not_to have_css('.badge')
      end
    end

    specify 'The badge increments when a reminder is unread' do
      find('.form-check-input').set(true)
      within 'aside.subscriber-side-navbar' do
        expect(page).to have_link('Notifications')
        expect(page).to have_css('.badge', text: 1)
      end
      click_button 'Mark as Unread'
      within 'aside.subscriber-side-navbar' do
        expect(page).to have_link('Notifications')
        expect(page).to have_css('.badge', text: 2)
      end
    end
  end
end
