# frozen_string_literal: true

require 'rails_helper'
RSpec.describe 'Sign In Authentication', type: :feature do
  it 'successfully redirects to the admin home page' do
    user = FactoryBot.create :user, role: 'admin'

    visit new_user_session_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Log In'

    expect(page).to have_current_path(admin_root_path)
    expect(page).not_to have_current_path(reporter_root_path)
    expect(page).not_to have_current_path(subscriber_root_path)
  end

  it 'successfully redirects to the reporter home page' do
    user = FactoryBot.create :user, role: 'reporter'

    visit new_user_session_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Log In'

    expect(page).to have_current_path(reporter_root_path)
    expect(page).not_to have_current_path(admin_root_path)
    expect(page).not_to have_current_path(subscriber_root_path)
  end

  it 'successfully redirects to the subscriber home page' do
    user = FactoryBot.create :user, role: 'subscriber'

    visit new_user_session_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Log In'

    expect(page).to have_current_path(subscriber_root_path)
    expect(page).not_to have_current_path(admin_root_path)
    expect(page).not_to have_current_path(reporter_root_path)
  end

  it 'redirects to the landing page if the user is not a recognised role' do
    user = FactoryBot.create :user, role: 'product-owner'

    visit new_user_session_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Log In'

    expect(page).to have_current_path(root_path)
    expect(page).not_to have_current_path(admin_root_path)
    expect(page).not_to have_current_path(reporter_root_path)
    expect(page).not_to have_current_path(subscriber_root_path)
  end
end
