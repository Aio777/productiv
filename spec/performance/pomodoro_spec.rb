# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Pomodoro', :js, type: :feature do
  let!(:subscriber) { FactoryBot.create(:user, role: 'subscriber') }

  before do
    login_as(subscriber, scope: :user)
  end

  it 'loads the pomodoro page in an acceptable time' do
    expect do
      visit subscriber_pomodoro_path

      expect(page).to have_content('Pomodoro Timer')
      expect(page).to have_css('[data-controller="pomodoro"]')
      expect(page).to have_css('[data-pomodoro-target="time"]')
      expect(page).to have_css('[data-pomodoro-target="toggleButton"] i.bi-play-fill')
      expect(page).to have_button('Show Floating Timer')
    end.to perform_under(1500).ms
  end

  it 'shows the floating widget in an acceptable time' do
    visit subscriber_pomodoro_path

    expect do
      click_button 'Show Floating Timer'

      expect(page).to have_css('.floating-pomodoro-widget', visible: true)
      expect(page).to have_css('[data-floating-pomodoro-target="time"]', visible: true)
      expect(page).to have_css('[data-action="floating-pomodoro#toggle"]', visible: true)
    end.to perform_under(1200).ms
  end
end
