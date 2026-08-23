# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Authorisation', type: :feature do
  describe 'login' do
    it 'allows admin to log in with valid credentials' do
      admin = FactoryBot.create(:user, role: 'admin')
      login_as admin, scope: :user
      visit admin_root_path
      expect(page).to have_current_path(admin_root_path)
      expect(page).to have_content('Logout')
    end

    it 'allows reporter to log in with valid credentials' do
      reporter = FactoryBot.create(:user, role: 'reporter')
      login_as reporter, scope: :user
      visit reporter_root_path
      expect(page).to have_current_path(reporter_root_path)
      expect(page).to have_content('Logout')
    end

    it 'allows admin to visit reporter path with valid credentials' do
      admin = FactoryBot.create(:user, role: 'admin')
      login_as admin, scope: :user
      visit reporter_root_path
      expect(page).to have_current_path(reporter_root_path)
      expect(page).to have_content('Logout')
    end

    it 'allows signee to log in with valid credentials' do
      signee = FactoryBot.create(:user, role: 'signee')
      login_as signee, scope: :user
      visit root_path
      expect(page).to have_current_path(root_path)
      expect(page).to have_content('Logout')
    end

    it 'allows non users to visit landing page' do
      visit root_path
      expect(page).to have_current_path(root_path)
      expect(page).to have_content('Log in')
    end

    it 'redirects reporter to home when not admin' do
      reporter = FactoryBot.create(:user, role: 'reporter')
      login_as reporter, scope: :user
      visit admin_root_path
      expect(page).not_to have_current_path(admin_root_path)
      expect(page).to have_content('Logout')
    end

    it 'redirects non admin log in with valid credentials' do
      signee = FactoryBot.create(:user, role: 'signee', password: 'Password@1234')
      login_as signee, scope: :user
      visit admin_root_path
      expect(page).not_to have_current_path(admin_root_path)
      expect(page).to have_content('Logout')
    end

    it 'redirects non users to login' do
      visit admin_root_path
      expect(page).not_to have_current_path(admin_root_path)
      expect(page).to have_content('Log In')
    end

    it 'redirects signee to home when not reporter' do
      signee = FactoryBot.create(:user, role: 'signee')
      login_as signee, scope: :user
      visit reporter_root_path
      expect(page).not_to have_current_path(reporter_root_path)
      expect(page).to have_content('Logout')
    end

    it 'redirects non user to login path when not reporter' do
      visit reporter_root_path
      expect(page).not_to have_current_path(reporter_root_path)
      expect(page).to have_content('Log In')
    end
  end
end
