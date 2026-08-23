# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Feature Cards', type: :feature do
  describe 'AI Task Breakdown Card' do
    it 'shows the AI Task Breakdown card on the landing page' do
      visit root_path

      within('.feature-card-container') do
        expect(page).to have_content('Task Breakdown Assistance with AI')
        expect(page).to have_content('Deconstruct complex projects into actionable tasks with AI integration')
      end
    end

    it 'opens the Read More modal when the Read More button associated with the AI Task Breakdown card is clicked',
       :js do
      visit root_path

      feature_card = find('.feature-card', text: 'Task Breakdown Assistance with AI')
      within(feature_card) do
        click_button 'Read More'
      end

      modal = find('#featuresModal', visible: true)
      expect(modal).to have_content('Not knowing what needs to be done for a large or complicated')
    end
  end

  describe 'Workspaces and Projects Card' do
    it 'shows the Workspaces and Projects card on the landing page' do
      visit root_path

      within('.feature-card-container') do
        expect(page).to have_content('Workspaces & Projects')
        expect(page).to have_content('Organise your work across multiple workspaces and projects')
      end
    end

    it 'opens the Read More modal when Read More button associated with the Workspaces and Projects card is clicked',
       :js do
      visit root_path

      feature_card = find('.feature-card', text: 'Workspaces & Projects')
      within(feature_card) do
        click_button 'Read More'
      end

      modal = find('#featuresModal', visible: true)
      expect(modal).to have_content('Organise your responsibilities and collaborate with your peers')
    end
  end

  describe 'Progress Visualisation Card' do
    it 'shows the Progress Visualisation card on the landing page' do
      visit root_path

      within('.feature-card-container') do
        expect(page).to have_content('Progress Visualisation')
        expect(page).to have_content('Track progress with key performance indicators')
      end
    end

    it 'opens the Read More modal when the Read More button associated with the Progress Visualisation card is clicked',
       :js do
      visit root_path

      feature_card = find('.feature-card', text: 'Progress Visualisation')
      within(feature_card) do
        click_button 'Read More'
      end

      modal = find('#featuresModal')
      expect(modal).to have_content('Understanding how much progress has been made towards a')
    end
  end

  describe 'Pomodoro Timer Card' do
    it 'shows the Pomodoro Timer card on the landing page' do
      visit root_path

      within('.feature-card-container') do
        expect(page).to have_content('Pomodoro Timer')
        expect(page).to have_content('Enhance productivity by working in focused intervals')
      end
    end

    it 'opens the Read More modal when the Read More button associated with the Pomodoro Timer card is clicked', :js do
      visit root_path

      feature_card = find('.feature-card', text: 'Pomodoro Timer')
      within(feature_card) do
        click_button 'Read More'
      end

      modal = find('#featuresModal', visible: true)
      expect(modal).to have_content('Reduce unhelpful distractions and maintain uninterrupted focus')
    end
  end

  describe 'Progress Rewards Card' do
    it 'shows the Progress Rewards card on the landing page' do
      visit root_path

      within('.feature-card-container') do
        expect(page).to have_content('Be Rewarded for Progress')
        expect(page).to have_content('Earn points for completing tasks, with more difficult tasks being more rewarding')
      end
    end

    it 'opens the Read More modal when the Read More button associated with the Progress Rewards card is clicked',
       :js do
      visit root_path

      feature_card = find('.feature-card', text: 'Be Rewarded for Progress')
      within(feature_card) do
        click_button 'Read More'
      end

      modal = find('#featuresModal', visible: true)
      expect(modal).to have_content('Feel accomplished when you complete a task, no matter the size,')
    end
  end

  describe 'Leaderboards Card' do
    it 'shows the Leaderboards card on the landing page' do
      visit root_path

      within('.feature-card-container') do
        expect(page).to have_content('Leaderboards')
        expect(page).to have_content('Compete with friends and teammates on designated leaderboards')
      end
    end

    it 'opens the Read More modal when the Read More button associated with the Leaderboards card is clicked', :js do
      visit root_path

      feature_card = find('.feature-card', text: 'Leaderboards')
      within(feature_card) do
        click_button 'Read More'
      end

      modal = find('#featuresModal', visible: true)
      expect(modal).to have_content('Challenge your friends or teammates to achieve the highest')
    end
  end

  describe 'Plant Card' do
    it 'shows the Plant card on the landing page' do
      visit root_path

      within('.feature-card-container') do
        expect(page).to have_content('Your Virtual Plant')
        expect(page).to have_content('Grow and customise your own plant using your hard earned points')
      end
    end

    it 'opens the Read More modal when the Read More button associated with the Plant card is clicked', :js do
      visit root_path

      feature_card = find('.feature-card', text: 'Your Virtual Plant')
      within(feature_card) do
        click_button 'Read More'
      end

      modal = find('#featuresModal')
      expect(modal).to have_content('A fun, engaging and interactive representation of the work you')
    end
  end
end
