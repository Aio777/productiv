# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Login', type: :feature do
  let!(:user) { FactoryBot.create(:user, role: 'admin') }

  it 'successfully logs a user in' do
    visit new_user_session_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Log In'
    expect(page).to have_current_path(admin_root_path)
  end

  it 'fails on wrong password' do
    visit new_user_session_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: 'WrongPassword'
    click_button 'Log In'
    expect(page).to have_current_path(new_user_session_path)
  end
end
