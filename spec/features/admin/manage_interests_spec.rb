# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin manages interest sign-ups:', type: :feature do
  let!(:admin) { create(:user, role: 'admin') }
  let!(:interest1) { create(:interest, name: 'Alice', email: 'alice@example.com') }

  before do
    create(:interest, name: 'Bob', email: 'bob@example.com')
    login_as(admin, scope: :user)
  end

  describe 'viewing interest signups' do
    it 'shows the list of interests' do
      visit admin_interests_path

      expect(page).to have_content('Alice')
      expect(page).to have_content('alice@example.com')
      expect(page).to have_content('Bob')
      expect(page).to have_content('bob@example.com')
    end

    it 'shows the registration journey of a user', :js do
      interested_user = FactoryBot.create(:interest)
      registration_visit = Ahoy::Visit.create!
      base_time = Time.current

      Ahoy::Event.create!(
        name: Metrics::LandingPageMetrics::AHOY_EVENT_NAMES[:VIEWED_TASK_BREAKDOWN_AI_FEATURE],
        visit: registration_visit,
        time: base_time - 3.minutes
      )

      Ahoy::Event.create!(
        name: Metrics::LandingPageMetrics::AHOY_EVENT_NAMES[:VIEWED_WORKSPACES_AND_PROJECTS_FEATURE],
        visit: registration_visit,
        time: base_time - 2.minutes
      )

      Ahoy::Event.create!(
        name: Metrics::LandingPageMetrics::AHOY_EVENT_NAMES[:VIEWED_LEADERBOARDS_FEATURE],
        visit: registration_visit,
        time: base_time - 1.minute
      )

      Ahoy::Event.create!(
        name: Metrics::LandingPageMetrics::AHOY_EVENT_NAMES[:REGISTERED_INTEREST],
        visit: registration_visit,
        time: base_time,
        properties: { 'registration_email' => interested_user.email }
      )

      logout(:user)

      visit root_path
      within('.feature-card-container') do
        card = find('.feature-card', text: 'Task Breakdown Assistance with AI')
        card.find('button', text: 'Read More').click
      end

      visit root_path
      within('.feature-card-container') do
        card = find('.feature-card', text: 'Workspaces & Projects')
        card.find('button', text: 'Read More').click
      end

      visit root_path
      within('.feature-card-container') do
        card = find('.feature-card', text: 'Leaderboards')
        card.find('button', text: 'Read More').click
      end

      login_as(admin, scope: :user)
      visit admin_interests_path
      expect(page).to have_current_path(admin_interests_path)
      within(:xpath, "//tr[td[contains(text(), '#{interested_user.email}')]]") do
        click_on 'Show'
      end

      expect(page).to have_css('#chart-1 svg')

      chart_text = find('#chart-1').text
      expect(chart_text).to include('Task')
      expect(chart_text).to include('Workspaces')
      expect(chart_text).to include('Leaderboards')
    end
  end

  describe 'deleting interests' do
    it 'allows admin to delete an interest' do
      visit admin_interests_path

      within(:xpath, "//tr[td[contains(text(), '#{interest1.email}')]]") do
        click_on 'Destroy'
      end

      expect(page).to have_current_path(admin_interests_path, ignore_query: true)
      expect(page).to have_no_css("#interest_#{interest1.id}")
      expect(page).not_to have_content('Alice')
    end
  end

  describe 'authorization' do
    it 'blocks non-admin users' do
      logout(:user)
      reporter = create(:user, role: 'reporter')

      login_as(reporter, scope: :user)
      visit admin_interests_path

      expect(page).to have_current_path(root_path)
    end

    it 'requires authentication' do
      logout(:user)

      visit admin_interests_path

      expect(page).to have_current_path(new_user_session_path)
    end
  end
end
