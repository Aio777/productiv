# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Subscriber dashboard performance', type: :feature do
  let!(:subscriber) do
    FactoryBot.create(
      :user,
      role: 'subscriber',
      first_name: 'Dashboard',
      last_name: 'Tester',
      layout: 15,
      points: 100
    )
  end

  let!(:ahoy_visit) { FactoryBot.create(:ahoy_visit, user: subscriber) }

  before do
    seed_dashboard_tasks
    seed_dashboard_events

    login_as(subscriber, scope: :user)
  end

  it 'loads the dashboard with all KPI charts and seeded graph data in an acceptable time' do
    expect do
      visit subscriber_root_path

      expect(page).to have_current_path(subscriber_root_path)
      expect(page).to have_content('My Dashboard')
      expect(page).to have_css('turbo-frame#sidebar_plant')
      expect(page).to have_button('Water')
      expect(page).to have_css('img.plant-layer', minimum: 3)

      expect(page).to have_content('Tasks Completed (Personal Workspace)')
      expect(page).to have_content('Pomodoro Sessions')
      expect(page).to have_content('Tasks Created (Personal Workspace)')
      expect(page).to have_content('Points Earned')
      expect(page).to have_css('[data-controller="chart"]', count: 4)
    end.to perform_under(2500).ms
  end

  def seed_dashboard_tasks
    15.times do |index|
      FactoryBot.create(
        :individual_task,
        name: "Completed Dashboard Task #{index + 1}",
        individual_project: subscriber.individual_project,
        due_date: (index + 1).days.ago,
        created_at: (index + 10).days.ago,
        updated_at: (index + 1).days.ago,
        status_complete: true,
        points: 10
      )
    end

    15.times do |index|
      FactoryBot.create(
        :individual_task,
        name: "Created Dashboard Task #{index + 1}",
        individual_project: subscriber.individual_project,
        due_date: (index + 1).days.from_now,
        created_at: index.days.ago,
        status_complete: false,
        points: 10
      )
    end
  end

  def seed_dashboard_events
    10.times do |index|
      FactoryBot.create(
        :ahoy_event,
        visit: ahoy_visit,
        user: subscriber,
        name: "User ##{subscriber.id} #{
          Metrics::FeatureEngagementMetrics::AHOY_EVENT_NAMES[:STARTED_POMODORO_TIMER_PREFIX]
        }",
        time: index.days.ago
      )
    end

    10.times do |index|
      FactoryBot.create(
        :ahoy_event,
        visit: ahoy_visit,
        user: subscriber,
        name: "User ##{subscriber.id} Earned 10 #{
          Metrics::GamificationMetrics::AHOY_EVENT_NAMES[:EARNED_POINTS_FROM_INDIVIDUAL_TASK_PREFIX]
        } ##{index + 1}",
        properties: { task_points: 10 },
        time: index.days.ago
      )
    end
  end
end
