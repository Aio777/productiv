# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'subscriber uses pomodoro timer', type: :feature do
  let!(:subscriber) { FactoryBot.create(:user, role: 'subscriber') }

  before do
    login_as(subscriber, scope: :user)
    visit subscriber_pomodoro_path
  end

  describe 'initial state' do
    it 'shows the default timer duration' do
      expect(page).to have_content('25 min')
      expect(page).to have_content('25:00')
    end

    it 'shows duration controls' do
      expect(page).to have_button('-')
      expect(page).to have_button('+')
    end

    it 'shows the play icon on the toggle button' do
      expect(page).to have_css('[data-pomodoro-target="toggleButton"] i.bi-play-fill')
    end
  end

  describe 'adjusting timer duration' do
    it 'increases the timer duration by 5 minutes', :js do
      expect(page).to have_content('25 min')
      expect(page).to have_content('25:00')

      find('[data-action="pomodoro#increase"]').click

      expect(page).to have_content('30 min')
      expect(page).to have_content('30:00')
    end

    it 'decreases the timer duration by 5 minutes', :js do
      expect(page).to have_content('25 min')
      expect(page).to have_content('25:00')

      find('[data-action="pomodoro#decrease"]').click

      expect(page).to have_content('20 min')
      expect(page).to have_content('20:00')
    end

    it 'does not increase beyond the maximum duration', :js do
      expect(page).to have_content('25 min')
      expect(page).to have_content('25:00')

      7.times { find('[data-action="pomodoro#increase"]').click }

      expect(page).to have_content('60 min')
      expect(page).to have_content('60:00')

      find('[data-action="pomodoro#increase"]').click

      expect(page).to have_content('60 min')
      expect(page).to have_content('60:00')
    end

    it 'does not decrease below the minimum duration' do
      expect(page).to have_content('25 min')
      expect(page).to have_content('25:00')

      4.times { find('[data-action="pomodoro#decrease"]').click }

      expect(page).to have_content('5 min')
      expect(page).to have_content('5:00')

      find('[data-action="pomodoro#decrease"]').click

      expect(page).to have_content('5 min')
      expect(page).to have_content('5:00')
    end
  end

  describe 'starting and pausing the timer' do
    it 'starts the timer when play is clicked', :js do
      find('[data-action="pomodoro#toggle"]').click
      expect(page).to have_css('[data-pomodoro-target="toggleButton"] i.bi-pause-fill')
      expect(page).not_to have_css('[data-pomodoro-target="controls"]')
      expect(page).not_to have_content('25 min')
      sleep 1
      expect(page).not_to have_content('25:00')
    end

    it 'hides duration controls when the timer starts', :js do
      find('[data-action="pomodoro#toggle"]').click
      expect(page).to have_css('[data-pomodoro-target="toggleButton"] i.bi-pause-fill')
      expect(page).not_to have_css('[data-pomodoro-target="controls"]')
    end

    it 'pauses the timer when pause is clicked', :js do
      find('[data-action="pomodoro#toggle"]').click
      expect(page).to have_css('[data-pomodoro-target="toggleButton"] i.bi-pause-fill')

      find('[data-action="pomodoro#toggle"]').click
      expect(page).to have_css('[data-pomodoro-target="toggleButton"] i.bi-play-fill')
      paused_time = find('[data-pomodoro-target="time"]').text
      sleep 2

      expect(find('[data-pomodoro-target="time"]').text).to eq(paused_time)
    end

    it 'resumes the timer when play is clicked again', :js do
      find('[data-action="pomodoro#toggle"]').click
      expect(page).to have_css('[data-pomodoro-target="toggleButton"] i.bi-pause-fill')

      find('[data-action="pomodoro#toggle"]').click
      expect(page).to have_css('[data-pomodoro-target="toggleButton"] i.bi-play-fill')
      paused_time = find('[data-pomodoro-target="time"]').text
      sleep 2

      expect(find('[data-pomodoro-target="time"]').text).to eq(paused_time)
      find('[data-action="pomodoro#toggle"]').click
      expect(page).to have_css('[data-pomodoro-target="toggleButton"] i.bi-pause-fill')

      expect(page).to have_no_css('[data-pomodoro-target="time"]', text: paused_time)
    end
  end

  describe 'resetting the timer' do
    it 'resets the timer to the selected duration', :js do
      expect(page).to have_content('25 min')
      find('[data-action="pomodoro#toggle"]').click
      expect(page).not_to have_content('25 min')
      expect(page).not_to have_css('[data-pomodoro-target="controls"]')
      expect(page).to have_css('[data-pomodoro-target="toggleButton"] i.bi-pause-fill')

      find('[data-action="pomodoro#reset"]').click

      expect(page).to have_content('25 min')
    end

    it 'shows duration controls again after reset', :js do
      expect(page).to have_content('25 min')
      find('[data-action="pomodoro#toggle"]').click
      expect(page).not_to have_content('25 min')
      expect(page).not_to have_css('[data-pomodoro-target="controls"]')
      expect(page).to have_css('[data-pomodoro-target="toggleButton"] i.bi-pause-fill')

      find('[data-action="pomodoro#reset"]').click

      expect(page).to have_content('25 min')
      expect(page).to have_css('[data-pomodoro-target="controls"]')
    end

    it 'resets the toggle button back to play', :js do
      expect(page).to have_content('25 min')
      find('[data-action="pomodoro#toggle"]').click
      expect(page).not_to have_content('25 min')
      expect(page).not_to have_css('[data-pomodoro-target="controls"]')
      expect(page).to have_css('[data-pomodoro-target="toggleButton"] i.bi-pause-fill')

      find('[data-action="pomodoro#reset"]').click

      expect(page).to have_content('25 min')
      expect(page).to have_css('[data-pomodoro-target="controls"]')
      expect(page).to have_css('[data-pomodoro-target="toggleButton"] i.bi-play-fill')
    end
  end

  describe 'timer completion' do
    it 'stops the timer when it reaches zero', :js do
      page.execute_script(<<~JS)
        const el = document.querySelector('[data-controller="pomodoro"]')
        const controller = Stimulus.getControllerForElementAndIdentifier(el, "pomodoro")
        controller.setDuration(2)
      JS

      find('[data-action="pomodoro#toggle"]').click
      sleep 3
      accept_alert 'Pomodoro complete'
      expect(page).to have_css('[data-pomodoro-target="time"]', text: '0:00')
    end

    it 'does not allow the timer to go below zero', :js do
      page.execute_script(<<~JS)
        const el = document.querySelector('[data-controller="pomodoro"]')
        const controller = Stimulus.getControllerForElementAndIdentifier(el, "pomodoro")
        controller.setDuration(2)
      JS

      find('[data-action="pomodoro#toggle"]').click

      sleep 4
      accept_alert 'Pomodoro complete'

      expect(find('[data-pomodoro-target="time"]').text).to eq('0:00')
    end

    it 'returns to the initial state after completion', :js do
      page.execute_script(<<~JS)
        const el = document.querySelector('[data-controller="pomodoro"]')
        const controller = Stimulus.getControllerForElementAndIdentifier(el, "pomodoro")
        controller.setDuration(1)
      JS

      accept_alert 'Pomodoro complete' do
        find('[data-action="pomodoro#toggle"]').click
      end

      find('[data-action="pomodoro#reset"]').click

      expect(page).to have_content('0:01')
      expect(page).to have_css('[data-pomodoro-target="controls"]', visible: true)
      expect(page).to have_css('[data-pomodoro-target="toggleButton"]', visible: true)
      expect(page).to have_css('[data-pomodoro-target="toggleButton"] i.bi-play-fill')
    end

    it 'does not allow restarting after completion', :js do
      page.execute_script(<<~JS)
        const el = document.querySelector('[data-controller="pomodoro"]')
        const controller = Stimulus.getControllerForElementAndIdentifier(el, "pomodoro")
        controller.setDuration(1)
      JS

      find('[data-action="pomodoro#toggle"]').click

      expect(page).to have_css('[data-pomodoro-target="toggleButton"]', visible: false)
    end
  end

  describe 'floating widget' do
    it 'shows the floating widget when enabled from the pomodoro page' do
      expect(page).to have_css('.floating-pomodoro-widget.d-none', visible: :all)

      click_button 'Show Floating Timer'

      expect(page).to have_css('.floating-pomodoro-widget', visible: true)
      expect(page).to have_css('[data-floating-pomodoro-target="time"]', text: '25:00', visible: true)
      expect(page).to have_css('[data-action="floating-pomodoro#toggle"]', visible: true)
      expect(page).to have_css('[data-action="floating-pomodoro#reset"]', visible: true)
    end

    it 'keeps the floating widget visible when navigating to another subscriber page' do
      click_button 'Show Floating Timer'

      expect(page).to have_css('.floating-pomodoro-widget', visible: true)

      visit subscriber_root_path

      expect(page).to have_css('.floating-pomodoro-widget', visible: true)
      expect(page).to have_css('[data-floating-pomodoro-target="time"]', text: '25:00', visible: true)
    end

    it 'hides the floating widget when the close button is clicked' do
      click_button 'Show Floating Timer'

      expect(page).to have_css('.floating-pomodoro-widget', visible: true)

      find('[data-action="floating-pomodoro#hide"]').click

      expect(page).to have_css('.floating-pomodoro-widget.d-none', visible: :all)
    end

    it 'shows the current selected duration in the floating widget when enabled', :js do
      find('[data-action="pomodoro#decrease"]').click

      expect(page).to have_content('20 min')
      expect(page).to have_content('20:00')

      click_button 'Show Floating Timer'

      expect(page).to have_css('[data-floating-pomodoro-target="time"]', text: '20:00', visible: true)
    end

    it 'continues counting down in the floating widget after navigating away', :js do
      page.execute_script(<<~JS)
        const el = document.querySelector('[data-controller="pomodoro"]')
        const controller = Stimulus.getControllerForElementAndIdentifier(el, "pomodoro")
        controller.setDuration(10)
      JS

      click_button 'Show Floating Timer'
      find('[data-action="pomodoro#toggle"]').click

      visit subscriber_root_path

      expect(page).to have_css('.floating-pomodoro-widget', visible: true)
      expect(page).to have_no_css('[data-floating-pomodoro-target="time"]', text: '0:10')
    end

    it 'can pause and resume from the floating widget', :js do
      page.execute_script(<<~JS)
        const el = document.querySelector('[data-controller="pomodoro"]')
        const controller = Stimulus.getControllerForElementAndIdentifier(el, "pomodoro")
        controller.setDuration(10)
      JS

      click_button 'Show Floating Timer'
      find('[data-action="pomodoro#toggle"]').click

      visit subscriber_root_path

      expect(page).to have_css('.floating-pomodoro-widget', visible: true)

      find('[data-action="floating-pomodoro#toggle"]').click
      paused_time = find('[data-floating-pomodoro-target="time"]').text
      sleep 2

      expect(find('[data-floating-pomodoro-target="time"]').text).to eq(paused_time)

      find('[data-action="floating-pomodoro#toggle"]').click
      expect(page).to have_no_css('[data-floating-pomodoro-target="time"]', text: paused_time)
    end

    it 'resets from the floating widget back to the stored duration', :js do
      page.execute_script(<<~JS)
        const el = document.querySelector('[data-controller="pomodoro"]')
        const controller = Stimulus.getControllerForElementAndIdentifier(el, "pomodoro")
        controller.setDuration(10)
      JS

      click_button 'Show Floating Timer'
      find('[data-action="pomodoro#toggle"]').click

      visit subscriber_root_path
      find('[data-action="floating-pomodoro#reset"]').click

      expect(page).to have_css('[data-floating-pomodoro-target="time"]', text: '0:10', visible: true)
    end
  end
end
