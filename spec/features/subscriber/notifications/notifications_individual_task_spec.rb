# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Individual task reminder notifications', type: :feature do
  let!(:subscriber) { FactoryBot.create(:user, role: 'subscriber', first_name: 'subscriber', last_name: 'user') }

  describe 'Notification Page reminder tab' do
    specify 'user gets a notification for an individual task with a reminder date of today after logging in' do
      task = FactoryBot.create(:individual_task, name: 'Reminder Today',
                                                 individual_project: subscriber.individual_project,
                                                 reminder_date: Date.current)

      visit new_user_session_path
      fill_in 'Email', with: subscriber.email
      fill_in 'Password', with: subscriber.password
      click_button 'Log In'

      expect(page).to have_current_path(subscriber_root_path)

      expect(Notification.count).to eq(1)

      visit "#{subscriber_notifications_path}?tab=reminders"

      expect(page).to have_content(task.name)
      expect(page).to have_css('.badge', text: '1')
      expect(Notification.last.user).to eq(subscriber)
      expect(Notification.last.individual_task).to eq(task)
      expect(Notification.last.message).to eq(task.name)
    end

    specify 'user does not get a notification for an individual task with a future reminder date after logging in' do
      task = FactoryBot.create(:individual_task, name: 'Reminder Tomorrow',
                                                 individual_project: subscriber.individual_project,
                                                 reminder_date: Date.tomorrow)

      visit new_user_session_path
      fill_in 'Email', with: subscriber.email
      fill_in 'Password', with: subscriber.password
      click_button 'Log In'

      expect(page).to have_current_path(subscriber_root_path)

      expect(Notification.count).to eq(0)

      visit "#{subscriber_notifications_path}?tab=reminders"

      expect(page).not_to have_content(task.name)
      expect(page).not_to have_css('.badge', text: '1')
    end

    specify 'user gets a notification for a task created two days ago with a reminder date of today after logging in' do
      task = FactoryBot.create(:individual_task, name: 'Old Task Reminder Today',
                                                 individual_project: subscriber.individual_project,
                                                 created_at: 2.days.ago, reminder_date: Date.current)

      visit new_user_session_path
      fill_in 'Email', with: subscriber.email
      fill_in 'Password', with: subscriber.password
      click_button 'Log In'

      expect(page).to have_current_path(subscriber_root_path)

      expect(Notification.count).to eq(1)

      visit "#{subscriber_notifications_path}?tab=reminders"

      expect(page).to have_content(task.name)
      expect(page).to have_css('.badge', text: '1')
      expect(Notification.last.user).to eq(subscriber)
      expect(Notification.last.individual_task).to eq(task)
      expect(Notification.last.message).to eq(task.name)
    end
  end
end
