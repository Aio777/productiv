# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Metrics::FeatureEngagementMetrics do
  let(:current_user) { FactoryBot.create(:user, role: 'subscriber') }
  let(:other_user1) { FactoryBot.create(:user, role: 'subscriber') }
  let(:other_user2) { FactoryBot.create(:user, role: 'subscriber') }

  def create_events_single_week(name)
    FactoryBot.create_list(:ahoy_event, 5, user: current_user, name: format(name, user_id: current_user.id))
    FactoryBot.create_list(:ahoy_event, 3, user: other_user1, name: format(name, user_id: other_user1.id))
    FactoryBot.create_list(:ahoy_event, 4, user: other_user2, name: format(name, user_id: other_user2.id))
  end

  def create_events_several_weeks(name)
    FactoryBot.create_list(:ahoy_event, 5, user: current_user, name: format(name, user_id: current_user.id))
    FactoryBot.create_list(
      :ahoy_event, 3, user: other_user1, name: format(name, user_id: other_user1.id), time: 2.weeks.ago
    )
    FactoryBot.create_list(
      :ahoy_event, 4, user: other_user2, name: format(name, user_id: other_user2.id), time: 1.month.ago
    )
  end

  context 'when looking across a single week,' do
    it '.pomodoro_timer_sessions_per_week returns the correct number of Pomodoro Timer Sessions started' do
      create_events_single_week("User #%<user_id>s #{
        Metrics::FeatureEngagementMetrics::AHOY_EVENT_NAMES[:STARTED_POMODORO_TIMER_PREFIX]
      }")

      expect(described_class.pomodoro_timer_sessions_per_week.count).to eq(1)
      expect(described_class.pomodoro_timer_sessions_per_week.value?(12)).to be true
    end

    it '.tasks_created_per_week returns the correct number of Tasks created' do
      create_events_single_week("User #%<user_id>s #{
        Metrics::FeatureEngagementMetrics::AHOY_EVENT_NAMES[:CREATED_INDIVIDUAL_TASK_PREFIX]
      } ##{rand(1..100)}")
      create_events_single_week("User #%<user_id>s #{
        Metrics::FeatureEngagementMetrics::AHOY_EVENT_NAMES[:CREATED_SHARED_TASK_PREFIX]
      } ##{rand(1..100)}")

      expect(described_class.tasks_created_per_week.count).to eq(1)
      expect(described_class.tasks_created_per_week.value?(24)).to be true
    end

    it '.tasks_completed_per_week returns the correct number of Tasks completed' do
      create_events_single_week("User #%<user_id>s #{
        Metrics::FeatureEngagementMetrics::AHOY_EVENT_NAMES[:COMPLETED_INDIVIDUAL_TASK_PREFIX]
      } ##{rand(1..100)}")
      create_events_single_week("User #%<user_id>s #{
        Metrics::FeatureEngagementMetrics::AHOY_EVENT_NAMES[:COMPLETED_SHARED_TASK_PREFIX]
      } ##{rand(1..100)}")

      expect(described_class.tasks_completed_per_week.count).to eq(1)
      expect(described_class.tasks_completed_per_week.value?(24)).to be true
    end

    it '.ai_task_breakdowns_per_week returns the correct number of AI Task Breakdowns' do
      create_events_single_week("User #%<user_id>s #{
        Metrics::FeatureEngagementMetrics::AHOY_EVENT_NAMES[:BREAKDOWN_AI_INDIVIDUAL_TASK_PREFIX]
      }")
      create_events_single_week("User #%<user_id>s #{
        Metrics::FeatureEngagementMetrics::AHOY_EVENT_NAMES[:BREAKDOWN_AI_SHARED_TASK_PREFIX]
      }")

      expect(described_class.ai_task_breakdowns_per_week.count).to eq(1)
      expect(described_class.ai_task_breakdowns_per_week.value?(24)).to be true
    end

    it '.reminders_per_week returns the correct number of Reminders' do
      create_events_single_week("User #%<user_id>s #{
        Metrics::FeatureEngagementMetrics::AHOY_EVENT_NAMES[:SET_REMINDER_ON_INDIVIDUAL_TASK_PREFIX]
      } ##{rand(1..100)}")
      create_events_single_week("User #%<user_id>s #{
        Metrics::FeatureEngagementMetrics::AHOY_EVENT_NAMES[:SET_REMINDER_ON_SHARED_TASK_PREFIX]
      } ##{rand(1..100)}")
      create_events_single_week("User #%<user_id>s #{
        Metrics::FeatureEngagementMetrics::AHOY_EVENT_NAMES[:UPDATED_REMINDER_ON_INDIVIDUAL_TASK_PREFIX]
      } ##{rand(1..100)}")
      create_events_single_week("User #%<user_id>s #{
        Metrics::FeatureEngagementMetrics::AHOY_EVENT_NAMES[:UPDATED_REMINDER_ON_SHARED_TASK_PREFIX]
      } ##{rand(1..100)}")

      expect(described_class.reminders_per_week.count).to eq(1)
      expect(described_class.reminders_per_week.value?(48)).to be true
    end

    it '.notifications_per_week returns the correct number of Notifications' do
      create_events_single_week("User #%<user_id>s #{
        Metrics::FeatureEngagementMetrics::AHOY_EVENT_NAMES[:ACCEPTED_TEAM_PROJECT_INVITATION_PREFIX]
      } ##{rand(1..100)}")
      create_events_single_week("User #%<user_id>s #{
        Metrics::FeatureEngagementMetrics::AHOY_EVENT_NAMES[:REJECTED_TEAM_PROJECT_INVITATION_PREFIX]
      } ##{rand(1..100)}")

      expect(described_class.notifications_per_week.count).to eq(1)
      expect(described_class.notifications_per_week.value?(24)).to be true
    end
  end

  context 'when looking across several weeks,' do
    it '.pomodoro_timer_sessions_per_week returns the correct number of Pomodoro Timer Sessions started' do
      create_events_several_weeks("User #%<user_id>s #{
        Metrics::FeatureEngagementMetrics::AHOY_EVENT_NAMES[:STARTED_POMODORO_TIMER_PREFIX]
      }")

      expect(described_class.pomodoro_timer_sessions_per_week.count).to eq(3)
      expect(Set.new(described_class.pomodoro_timer_sessions_per_week.values)).to eq(Set[5, 3, 4])
    end

    it '.tasks_created_per_week returns the correct number of Tasks created' do
      create_events_several_weeks("User #%<user_id>s #{
        Metrics::FeatureEngagementMetrics::AHOY_EVENT_NAMES[:CREATED_INDIVIDUAL_TASK_PREFIX]
      } ##{rand(1..100)}")
      create_events_several_weeks("User #%<user_id>s #{
        Metrics::FeatureEngagementMetrics::AHOY_EVENT_NAMES[:CREATED_SHARED_TASK_PREFIX]
      } ##{rand(1..100)}")

      expect(described_class.tasks_created_per_week.count).to eq(3)
      expect(Set.new(described_class.tasks_created_per_week.values)).to eq(Set[10, 6, 8])
    end

    it '.tasks_completed_per_week returns the correct number of Tasks completed' do
      create_events_several_weeks("User #%<user_id>s #{
        Metrics::FeatureEngagementMetrics::AHOY_EVENT_NAMES[:COMPLETED_INDIVIDUAL_TASK_PREFIX]
      } ##{rand(1..100)}")
      create_events_several_weeks("User #%<user_id>s #{
        Metrics::FeatureEngagementMetrics::AHOY_EVENT_NAMES[:COMPLETED_SHARED_TASK_PREFIX]
      } ##{rand(1..100)}")

      expect(described_class.tasks_completed_per_week.count).to eq(3)
      expect(Set.new(described_class.tasks_completed_per_week.values)).to eq(Set[10, 6, 8])
    end

    it '.ai_task_breakdowns_per_week returns the correct number of AI Task Breakdowns' do
      create_events_several_weeks("User #%<user_id>s #{
        Metrics::FeatureEngagementMetrics::AHOY_EVENT_NAMES[:BREAKDOWN_AI_INDIVIDUAL_TASK_PREFIX]
      }")
      create_events_several_weeks("User #%<user_id>s #{
        Metrics::FeatureEngagementMetrics::AHOY_EVENT_NAMES[:BREAKDOWN_AI_SHARED_TASK_PREFIX]
      }")

      expect(described_class.ai_task_breakdowns_per_week.count).to eq(3)
      expect(Set.new(described_class.ai_task_breakdowns_per_week.values)).to eq(Set[10, 6, 8])
    end

    it '.reminders_per_week returns the correct number of Reminders' do
      create_events_several_weeks("User #%<user_id>s #{
        Metrics::FeatureEngagementMetrics::AHOY_EVENT_NAMES[:SET_REMINDER_ON_INDIVIDUAL_TASK_PREFIX]
      } ##{rand(1..100)}")
      create_events_several_weeks("User #%<user_id>s #{
        Metrics::FeatureEngagementMetrics::AHOY_EVENT_NAMES[:SET_REMINDER_ON_SHARED_TASK_PREFIX]
      } ##{rand(1..100)}")
      create_events_several_weeks("User #%<user_id>s #{
        Metrics::FeatureEngagementMetrics::AHOY_EVENT_NAMES[:UPDATED_REMINDER_ON_INDIVIDUAL_TASK_PREFIX]
      } ##{rand(1..100)}")
      create_events_several_weeks("User #%<user_id>s #{
        Metrics::FeatureEngagementMetrics::AHOY_EVENT_NAMES[:UPDATED_REMINDER_ON_SHARED_TASK_PREFIX]
      } ##{rand(1..100)}")

      expect(described_class.reminders_per_week.count).to eq(3)
      expect(Set.new(described_class.reminders_per_week.values)).to eq(Set[20, 12, 16])
    end

    it '.notifications_per_week returns the correct number of Notifications' do
      create_events_several_weeks("User #%<user_id>s #{
        Metrics::FeatureEngagementMetrics::AHOY_EVENT_NAMES[:ACCEPTED_TEAM_PROJECT_INVITATION_PREFIX]
      } ##{rand(1..100)}")
      create_events_several_weeks("User #%<user_id>s #{
        Metrics::FeatureEngagementMetrics::AHOY_EVENT_NAMES[:REJECTED_TEAM_PROJECT_INVITATION_PREFIX]
      } ##{rand(1..100)}")

      expect(described_class.notifications_per_week.count).to eq(3)
      expect(Set.new(described_class.notifications_per_week.values)).to eq(Set[10, 6, 8])
    end
  end

  it '.pomodoro_timer_sessions_per_week returns nothing when no Pomodoro Timer Sessions have been started' do
    create_events_single_week("User #%<user_id>s #{
        Metrics::FeatureEngagementMetrics::AHOY_EVENT_NAMES[:BREAKDOWN_AI_INDIVIDUAL_TASK_PREFIX]
      }")

    expect(described_class.pomodoro_timer_sessions_per_week.empty?).to be true
  end

  it '.tasks_created_per_week returns nothing when no Tasks have been created' do
    create_events_single_week("User #%<user_id>s #{
        Metrics::FeatureEngagementMetrics::AHOY_EVENT_NAMES[:BREAKDOWN_AI_INDIVIDUAL_TASK_PREFIX]
      }")

    expect(described_class.tasks_created_per_week.empty?).to be true
  end

  it '.tasks_completed_per_week returns nothing when no Tasks have been completed' do
    create_events_single_week("User #%<user_id>s #{
        Metrics::FeatureEngagementMetrics::AHOY_EVENT_NAMES[:BREAKDOWN_AI_INDIVIDUAL_TASK_PREFIX]
      }")

    expect(described_class.tasks_completed_per_week.empty?).to be true
  end

  it '.ai_task_breakdowns_per_week returns nothing when no Tasks have been broken down using AI' do
    create_events_single_week("User #%<user_id>s #{
        Metrics::FeatureEngagementMetrics::AHOY_EVENT_NAMES[:STARTED_POMODORO_TIMER_PREFIX]
      }")

    expect(described_class.ai_task_breakdowns_per_week.empty?).to be true
  end

  it '.reminders_per_week returns nothing when no Reminders have been made' do
    create_events_single_week("User #%<user_id>s #{
        Metrics::FeatureEngagementMetrics::AHOY_EVENT_NAMES[:BREAKDOWN_AI_INDIVIDUAL_TASK_PREFIX]
      }")

    expect(described_class.reminders_per_week.empty?).to be true
  end

  it '.notifications_per_week returns nothing when no Notifications have been made' do
    create_events_single_week("User #%<user_id>s #{
        Metrics::FeatureEngagementMetrics::AHOY_EVENT_NAMES[:BREAKDOWN_AI_INDIVIDUAL_TASK_PREFIX]
      }")

    expect(described_class.notifications_per_week.empty?).to be true
  end

  describe '.feature_engagement_metrics' do
    it 'returns the correct metric data' do
      expect(described_class.feature_engagement_metrics).to eq(
        { pomodoro_sessions:
          { title: 'Pomodoro Sessions By Week', label: 'Sessions', values: {}.to_json, continuous: true,
            time_unit: 'week' },
          tasks_created:
          { title: 'Tasks Created By Week', label: 'Tasks Created', values: {}.to_json, continuous: true,
            time_unit: 'week' },
          tasks_completed:
          { title: 'Tasks Completed By Week', label: 'Tasks Completed', values: {}.to_json, continuous: true,
            time_unit: 'week' },
          ai_task_breakdowns:
          { title: 'AI Task Breakdowns By Week', label: 'AI Task Breakdowns', values: {}.to_json, continuous: true,
            time_unit: 'week' },
          reminders:
          { title: 'Reminders By Week', label: 'Reminders', values: {}.to_json, continuous: true, time_unit: 'week' },
          notifications:
          { title: 'Notifications By Week', label: 'Notifications', values: {}.to_json, continuous: true,
            time_unit: 'week' } }
      )
    end
  end
end
