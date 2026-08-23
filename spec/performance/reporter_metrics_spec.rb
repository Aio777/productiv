# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Reporter metrics performance', type: :feature do
  let!(:reporter) { FactoryBot.create(:user, role: 'reporter') }
  let!(:subscriber_one) { FactoryBot.create(:user, role: 'subscriber', first_name: 'Metric', last_name: 'One') }
  let!(:subscriber_two) { FactoryBot.create(:user, role: 'subscriber', first_name: 'Metric', last_name: 'Two') }
  let!(:subscriber_one_visit) { FactoryBot.create(:ahoy_visit, user: subscriber_one) }
  let!(:subscriber_two_visit) { FactoryBot.create(:ahoy_visit, user: subscriber_two) }

  before do
    seed_feature_engagement_events
    seed_gamification_events

    login_as(reporter, scope: :user)
  end

  around(:each, :without_bullet) do |example|
    bullet_enabled = Bullet.enable?
    Bullet.enable = false

    example.run
  ensure
    Bullet.enable = bullet_enabled
  end

  it 'loads feature engagement metrics with seeded event data in an acceptable time' do
    expect do
      visit reporter_feature_engagement_metrics_path

      expect(page).to have_content('Feature Engagement Metrics')
      expect(page).to have_content('Pomodoro Sessions By Week')
      expect(page).to have_content('Tasks Created By Week')
      expect(page).to have_content('Tasks Completed By Week')
      expect(page).to have_content('AI Task Breakdowns By Week')
      expect(page).to have_content('Reminders By Week')
      expect(page).to have_content('Notifications By Week')
      expect(page).to have_css('[data-controller="chart"]', count: 6)
    end.to perform_under(2500).ms
  end

  it 'loads gamification metrics with seeded event data in an acceptable time', :without_bullet do
    expect do
      visit reporter_gamification_metrics_path

      expect(page).to have_content('Gamification Metrics')
      expect(page).to have_content('Shop Purchases By Week')
      expect(page).to have_content('Points Earned Per User By Week')
      expect(page).to have_content('Plant Deaths By Week')
      expect(page).to have_content('Average Plant Streak Time')
      expect(page).to have_css('[data-controller="chart"]', count: 3)
      expect(page).to have_css('#average-plant-streak-time table')
    end.to perform_under(2500).ms
  end

  def seed_feature_engagement_events
    feature_events = [
      Metrics::FeatureEngagementMetrics::AHOY_EVENT_NAMES[:STARTED_POMODORO_TIMER_PREFIX],
      Metrics::FeatureEngagementMetrics::AHOY_EVENT_NAMES[:CREATED_INDIVIDUAL_TASK_PREFIX],
      Metrics::FeatureEngagementMetrics::AHOY_EVENT_NAMES[:CREATED_SHARED_TASK_PREFIX],
      Metrics::FeatureEngagementMetrics::AHOY_EVENT_NAMES[:COMPLETED_INDIVIDUAL_TASK_PREFIX],
      Metrics::FeatureEngagementMetrics::AHOY_EVENT_NAMES[:COMPLETED_SHARED_TASK_PREFIX],
      Metrics::FeatureEngagementMetrics::AHOY_EVENT_NAMES[:BREAKDOWN_AI_INDIVIDUAL_TASK_PREFIX],
      Metrics::FeatureEngagementMetrics::AHOY_EVENT_NAMES[:BREAKDOWN_AI_SHARED_TASK_PREFIX],
      Metrics::FeatureEngagementMetrics::AHOY_EVENT_NAMES[:SET_REMINDER_ON_INDIVIDUAL_TASK_PREFIX],
      Metrics::FeatureEngagementMetrics::AHOY_EVENT_NAMES[:SET_REMINDER_ON_SHARED_TASK_PREFIX],
      Metrics::FeatureEngagementMetrics::AHOY_EVENT_NAMES[:UPDATED_REMINDER_ON_INDIVIDUAL_TASK_PREFIX],
      Metrics::FeatureEngagementMetrics::AHOY_EVENT_NAMES[:UPDATED_REMINDER_ON_SHARED_TASK_PREFIX],
      Metrics::FeatureEngagementMetrics::AHOY_EVENT_NAMES[:ACCEPTED_TEAM_PROJECT_INVITATION_PREFIX],
      Metrics::FeatureEngagementMetrics::AHOY_EVENT_NAMES[:REJECTED_TEAM_PROJECT_INVITATION_PREFIX]
    ]

    feature_events.each_with_index do |event_name, index|
      create_event(
        user: subscriber_one,
        visit: subscriber_one_visit,
        name: "User ##{subscriber_one.id} #{event_name} ##{index + 1}",
        time: index.days.ago
      )
    end
  end

  def seed_gamification_events
    8.times do |index|
      create_event(
        user: subscriber_one,
        visit: subscriber_one_visit,
        name: "User ##{subscriber_one.id} #{
          Metrics::GamificationMetrics::AHOY_EVENT_NAMES[:PURCHASED_ITEM_PREFIX]
        } ##{index + 1}",
        time: index.days.ago
      )

      create_event(
        user: subscriber_one,
        visit: subscriber_one_visit,
        name: "User ##{subscriber_one.id} Earned 10 #{
          Metrics::GamificationMetrics::AHOY_EVENT_NAMES[:EARNED_POINTS_FROM_INDIVIDUAL_TASK_PREFIX]
        } ##{index + 1}",
        properties: { task_points: 10 },
        time: index.days.ago
      )

      create_event(
        user: subscriber_two,
        visit: subscriber_two_visit,
        name: "User ##{subscriber_two.id} Earned 12 #{
          Metrics::GamificationMetrics::AHOY_EVENT_NAMES[:EARNED_POINTS_FROM_SHARED_TASK_PREFIX]
        } ##{index + 1}",
        properties: { task_points: 12 },
        time: index.days.ago
      )
    end

    seed_plant_lifecycle_events(subscriber_one, subscriber_one_visit)
    seed_plant_lifecycle_events(subscriber_two, subscriber_two_visit)
  end

  def seed_plant_lifecycle_events(user, visit)
    plant_id = Plant.where(user_id: user.id).pick(:id)

    create_event(
      user: user,
      visit: visit,
      name: "Plant ##{plant_id} From User ##{user.id} #{
        Metrics::GamificationMetrics::AHOY_EVENT_NAMES[:PLANT_BROUGHT_TO_LIFE_PREFIX]
      }",
      time: 14.days.ago
    )

    create_event(
      user: user,
      visit: visit,
      name: "Plant ##{plant_id} From User ##{user.id} #{
        Metrics::GamificationMetrics::AHOY_EVENT_NAMES[:PLANT_DIED_PREFIX]
      }",
      time: 7.days.ago
    )
  end

  def create_event(user:, visit:, name:, time:, properties: {})
    FactoryBot.create(
      :ahoy_event,
      user: user,
      visit: visit,
      name: name,
      properties: properties,
      time: time
    )
  end
end
