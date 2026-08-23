# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Subscriber::Dashboard', :js, type: :feature do
  let!(:subscriber) { FactoryBot.create(:user, role: 'subscriber') }

  before do
    login_as(subscriber, scope: :user)
    visit subscriber_root_path
  end

  describe 'charts' do
    it 'shows the subscriber their charts' do
      expect(page).to have_content('Tasks Completed (Personal Workspace)')
    end

    it 'shows the subscriber can turn off a chart' do
      click_on 'Toggle Graphs'
      uncheck 'Tasks Completed'
      click_on 'Apply'

      expect(page).not_to have_content('Tasks Completed (Personal Workspace)')
    end

    it 'the visibility stays hidden when going off page' do
      click_on 'Toggle Graphs'
      uncheck 'Tasks Completed'
      click_on 'Apply'

      expect(page).not_to have_content('Tasks Completed (Personal Workspace)')

      visit root_path
      visit subscriber_root_path

      expect(page).not_to have_content('Tasks Completed (Personal Workspace)')
    end

    it 'allows switching between chart types' do
      find("input[type='radio'][value='bar']").click
      expect(page).to have_checked_field(nil, with: 'bar')

      find("input[type='radio'][value='line']").click
      expect(page).to have_checked_field(nil, with: 'line')
      expect(page).to have_unchecked_field(nil, with: 'bar')
    end

    it 'allows changing the start date' do
      within(:css, '#tasks-completed-personal-workspace') do
        fill_in 'Start From:', with: '01-15-2026'
        expect(page).to have_field('start-date-tasks-completed-personal-workspace', with: '2026-01-15')
      end
    end
  end

  describe 'plant' do
    it 'shows the subscriber their plant' do
      expect(page).to have_css('img.plant-layer')
    end
  end
end
