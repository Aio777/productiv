# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Logout', type: :feature do
  it 'logs out and redirects to root' do
    admin = FactoryBot.create(:user, password: 'Password@1234', role: 'admin')
    login_as admin, scope: :user
    visit admin_root_path
    click_button 'Logout'
    expect(page).to have_current_path(root_path)
    expect(page).to have_content('Log in')
  end

  it 'blocks access for admin after logout' do
    admin = FactoryBot.create(:user, password: 'Password@1234', role: 'admin')
    login_as admin, scope: :user
    visit admin_root_path
    click_button 'Logout'
    visit admin_root_path
    expect(page).to have_current_path(new_user_session_path)
    expect(page).to have_content('Log In')
  end

  it 'blocks access for reporter after logout' do
    reporter = FactoryBot.create(:user, password: 'Password@1234', role: 'reporter')
    login_as reporter, scope: :user
    visit reporter_root_path
    click_button 'Logout'
    visit reporter_root_path
    expect(page).to have_current_path(new_user_session_path)
    expect(page).to have_content('Log In')
  end
end
