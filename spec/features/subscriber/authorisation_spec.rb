# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Authorisation', type: :feature do
  describe 'login' do
    it 'allows subscriber to log in with valid credentials' do
      subscriber = FactoryBot.create(:user, role: 'subscriber')
      login_as subscriber, scope: :user
      visit subscriber_root_path
      expect(page).to have_current_path(subscriber_root_path)
      expect(page).to have_content('Logout')
      expect(page).to have_content('Notifications')
      expect(page).to have_content('Dashboard')
      expect(page).to have_content('Personal Workspace')
      expect(page).to have_content('Shared Projects')
      expect(page).to have_content('Item Shop')
    end

    it 'allows unregistered user to sign up and log in' do
      visit root_path
      click_link 'Get Productiv!'
      expect(page).to have_current_path(new_user_registration_path)
      fill_in 'First name', with: 'Test'
      fill_in 'Last name', with: 'User'
      fill_in 'Email', with: 'test@example.com'
      fill_in 'Password', with: 'Password@1234'
      fill_in 'Password confirmation', with: 'Password@1234'
      click_button 'Sign Up'
      expect(page).to have_current_path(subscriber_root_path)
      expect(page).to have_content('Logout')
      expect(page).to have_content('Notifications')
      expect(page).to have_content('Dashboard')
      expect(page).to have_content('Personal Workspace')
      expect(page).to have_content('Shared Projects')
      expect(page).to have_content('Item Shop')
    end

    it 'redirects reporter to home when not subscriber' do
      reporter = FactoryBot.create(:user, role: 'reporter')
      login_as reporter, scope: :user
      visit subscriber_root_path
      expect(page).not_to have_current_path(subscriber_root_path)
      expect(page).to have_content('Logout')
    end

    it 'redirects admin to home when not subscriber' do
      admin = FactoryBot.create(:user, role: 'admin')
      login_as admin, scope: :user
      visit subscriber_root_path
      expect(page).not_to have_current_path(subscriber_root_path)
      expect(page).to have_content('Logout')
    end

    it 'redirects signee to home when not subscriber' do
      signee = FactoryBot.create(:user, role: 'signee')
      login_as signee, scope: :user
      visit subscriber_root_path
      expect(page).not_to have_current_path(subscriber_root_path)
      expect(page).to have_content('Logout')
    end

    it 'redirects non user to home when not subscriber' do
      visit subscriber_root_path
      expect(page).not_to have_current_path(subscriber_root_path)
      expect(page).to have_content('Log In')
    end
  end
end
