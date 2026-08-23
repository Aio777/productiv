# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'subscriber uses AI task breakdown', type: :feature do
  let!(:subscriber) { FactoryBot.create(:user, role: 'subscriber') }

  before do
    login_as(subscriber, scope: :user)
  end

  describe 'opening AI task breakdown from workspace shows an error message' do
    before do
      allow(Ai::GeminiClient).to receive(:generate_text).and_raise(
        Ai::GeminiClient::Error,
        'API unavailable'
      )
    end

    it 'from an existing personal task', :js do
      task = FactoryBot.create(
        :individual_task,
        name: 'Task 1',
        description: 'Task 1 description',
        individual_project: subscriber.individual_project,
        due_date: 1.day.from_now
      )

      visit subscriber_project_path
      click_on 'Task 1'

      expect(page).to have_text('Task Details')
      expect(page).to have_field('Task name', with: task.name)

      first('.ai-button').click

      expect(page).to have_text('AI Task Breakdown')
      expect(page).to have_text('Failed to generate breakdown.')
    end

    it 'from the new personal task form', :js do
      visit subscriber_project_path
      click_on '+ Task'

      fill_in 'Task name', with: 'Write report'
      fill_in 'Description', with: 'Finish the draft and references'

      first('.ai-button').click

      expect(page).to have_text('AI Task Breakdown')
      expect(page).to have_text('Failed to generate breakdown.')
    end

    it 'from an existing shared project task', :js do
      team_project = FactoryBot.create(
        :team_project,
        name: 'AI Shared Project'
      )

      FactoryBot.create(
        :team_project_member,
        :team_lead,
        user: subscriber,
        team_project: team_project
      )

      shared_task = FactoryBot.create(
        :team_project_task,
        team_project: team_project,
        name: 'Shared AI Task',
        description: 'Shared AI task description',
        due_date: 1.day.from_now,
        difficulty: 'easy'
      )

      visit subscriber_shared_project_path(team_project)
      click_on 'Shared AI Task'

      expect(page).to have_text('Task Details')
      expect(page).to have_field('Task name', with: shared_task.name)

      first('.ai-button').click

      expect(page).to have_text('AI Task Breakdown')
      expect(page).to have_text('Failed to generate breakdown.')
    end
  end

  describe 'validation' do
    it 'shows an error if task name is empty', :js do
      visit subscriber_project_path
      click_on '+ Task'

      first('.ai-button').click

      expect(page).to have_text('Please enter a task name first.')
    end
  end
end
