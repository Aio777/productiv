# frozen_string_literal: true

# Module containing methods to be used by product owners to track engagement for the different app features
module Metrics::FeatureEngagementMetrics
  AHOY_EVENT_NAMES = {
    CREATED_INDIVIDUAL_TASK_PREFIX: 'Created Individual Task',
    CREATED_SHARED_TASK_PREFIX: 'Created Shared Task',

    COMPLETED_INDIVIDUAL_TASK_PREFIX: 'Completed Individual Task',
    COMPLETED_SHARED_TASK_PREFIX: 'Completed Shared Task',

    SET_REMINDER_ON_INDIVIDUAL_TASK_PREFIX: 'Set Reminder on Individual Task',
    SET_REMINDER_ON_SHARED_TASK_PREFIX: 'Set Reminder on Shared Task',

    UPDATED_REMINDER_ON_INDIVIDUAL_TASK_PREFIX: 'Updated Reminder on Individual Task',
    UPDATED_REMINDER_ON_SHARED_TASK_PREFIX: 'Updated Reminder on Shared Task',

    STARTED_POMODORO_TIMER_PREFIX: 'Started Pomodoro Timer',

    BREAKDOWN_AI_INDIVIDUAL_TASK_PREFIX: 'Used AI Breakdown for an Individual Task',
    BREAKDOWN_AI_SHARED_TASK_PREFIX: 'Used AI Breakdown for a Shared Task',

    ACCEPTED_TEAM_PROJECT_INVITATION_PREFIX: 'Accepted Joining Team Project',
    REJECTED_TEAM_PROJECT_INVITATION_PREFIX: 'Rejected Joining Team Project'
  }.freeze

  def self.pomodoro_timer_sessions_per_week
    pomodoro_timer_session_events = Ahoy::Event.where(
      'name LIKE ?',
      "%#{AHOY_EVENT_NAMES[:STARTED_POMODORO_TIMER_PREFIX]}"
    )

    GroupRecords.group_records_by_time(pomodoro_timer_session_events, :time, nil, :week)
  end

  def self.tasks_created_per_week
    created_task_events = Ahoy::Event.where('name LIKE ?', "%#{AHOY_EVENT_NAMES[:CREATED_INDIVIDUAL_TASK_PREFIX]}%").or(
      Ahoy::Event.where('name LIKE ?', "%#{AHOY_EVENT_NAMES[:CREATED_SHARED_TASK_PREFIX]}%")
    )

    GroupRecords.group_records_by_time(created_task_events, :time, nil, :week)
  end

  def self.tasks_completed_per_week
    completed_task_events = Ahoy::Event.where(
      'name LIKE ?',
      "%#{AHOY_EVENT_NAMES[:COMPLETED_INDIVIDUAL_TASK_PREFIX]}%"
    ).or(Ahoy::Event.where('name LIKE ?', "%#{AHOY_EVENT_NAMES[:COMPLETED_SHARED_TASK_PREFIX]}%"))

    GroupRecords.group_records_by_time(completed_task_events, :time, nil, :week)
  end

  def self.ai_task_breakdowns_per_week
    ai_task_breakdown_events = Ahoy::Event.where(
      'name LIKE ?',
      "%#{AHOY_EVENT_NAMES[:BREAKDOWN_AI_INDIVIDUAL_TASK_PREFIX]}%"
    ).or(Ahoy::Event.where('name LIKE ?', "%#{AHOY_EVENT_NAMES[:BREAKDOWN_AI_SHARED_TASK_PREFIX]}%"))

    GroupRecords.group_records_by_time(ai_task_breakdown_events, :time, nil, :week)
  end

  def self.reminders_per_week
    reminder_events = Ahoy::Event.where(
      'name LIKE ?', "%#{AHOY_EVENT_NAMES[:SET_REMINDER_ON_INDIVIDUAL_TASK_PREFIX]}%"
    ).or(
      Ahoy::Event.where('name LIKE ?', "%#{AHOY_EVENT_NAMES[:SET_REMINDER_ON_SHARED_TASK_PREFIX]}%")
    ).or(
      Ahoy::Event.where('name LIKE ?', "%#{AHOY_EVENT_NAMES[:UPDATED_REMINDER_ON_INDIVIDUAL_TASK_PREFIX]}%")
    ).or(
      Ahoy::Event.where('name LIKE ?', "%#{AHOY_EVENT_NAMES[:UPDATED_REMINDER_ON_SHARED_TASK_PREFIX]}%")
    )

    GroupRecords.group_records_by_time(reminder_events, :time, nil, :week)
  end

  def self.notifications_per_week
    notification_events = Ahoy::Event.where(
      'name LIKE ?',
      "%#{AHOY_EVENT_NAMES[:ACCEPTED_TEAM_PROJECT_INVITATION_PREFIX]}%"
    ).or(Ahoy::Event.where('name LIKE ?', "%#{AHOY_EVENT_NAMES[:REJECTED_TEAM_PROJECT_INVITATION_PREFIX]}%"))

    GroupRecords.group_records_by_time(notification_events, :time, nil, :week)
  end

  def self.feature_engagement_metrics
    feature_engagement_metrics = {}

    feature_engagement_metrics[:pomodoro_sessions] =
      { title: 'Pomodoro Sessions By Week', label: 'Sessions', values: pomodoro_timer_sessions_per_week.to_json,
        continuous: true, time_unit: 'week' }

    feature_engagement_metrics[:tasks_created] =
      { title: 'Tasks Created By Week', label: 'Tasks Created', values: tasks_created_per_week.to_json,
        continuous: true, time_unit: 'week' }

    feature_engagement_metrics[:tasks_completed] =
      { title: 'Tasks Completed By Week', label: 'Tasks Completed', values: tasks_completed_per_week.to_json,
        continuous: true, time_unit: 'week' }

    feature_engagement_metrics[:ai_task_breakdowns] =
      { title: 'AI Task Breakdowns By Week', label: 'AI Task Breakdowns', values: ai_task_breakdowns_per_week.to_json,
        continuous: true, time_unit: 'week' }

    feature_engagement_metrics[:reminders] =
      { title: 'Reminders By Week', label: 'Reminders', values: reminders_per_week.to_json, continuous: true,
        time_unit: 'week' }

    feature_engagement_metrics[:notifications] =
      { title: 'Notifications By Week', label: 'Notifications', values: notifications_per_week.to_json,
        continuous: true, time_unit: 'week' }

    feature_engagement_metrics
  end
end
