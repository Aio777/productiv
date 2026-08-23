# frozen_string_literal: true

# Module containing methods to be used by product owners to track user growth
module Metrics::UserGrowthMetrics
  AHOY_EVENT_NAMES = {
    USER_SIGNED_IN_PREFIX: 'Signed in'
  }.freeze

  def self.active_users(group_by)
    case group_by
    when :day
      active_users_times = Ahoy::Event.where('name LIKE ?', "%#{
        AHOY_EVENT_NAMES[:USER_SIGNED_IN_PREFIX]
      }").group_by_day(:time, series: false).group(:user_id).count
    when :week
      active_users_times = Ahoy::Event.where('name LIKE ?', "%#{
        AHOY_EVENT_NAMES[:USER_SIGNED_IN_PREFIX]
      }").group_by_week(:time, series: false, week_start: :monday).group(:user_id).count
    when :month
      active_users_times = Ahoy::Event.where('name LIKE ?', "%#{
        AHOY_EVENT_NAMES[:USER_SIGNED_IN_PREFIX]
      }").group_by_month(:time, series: false).group(:user_id).count
    end

    active_users_times = sort_active_users_by_time_asc(active_users_times)
    active_users_times = format_active_user_times(active_users_times, group_by)
    active_users_times.transform_values(&:count)
  end

  def self.user_growth_metrics
    user_growth_metrics = {}

    user_growth_metrics[:daily_active_users] =
      { title: 'Active Users By Day', label: 'Active Users', values: active_users(:day).to_json,
        continuous: true, time_unit: 'day' }

    user_growth_metrics[:weekly_active_users] =
      { title: 'Active Users By Week', label: 'Active Users', values: active_users(:week).to_json,
        continuous: true, time_unit: 'week' }

    user_growth_metrics[:monthly_active_users] =
      { title: 'Active Users By Month', label: 'Active Users', values: active_users(:month).to_json,
        continuous: true, time_unit: 'month' }

    user_growth_metrics
  end

  def self.sort_active_users_by_time_asc(active_users_times)
    active_users_times.sort_by { |((time, _user_id), _count)| time }
  end

  def self.format_active_user_times(active_users_times, group_by)
    active_users_times.each_with_object(Hash.new { |hash, key| hash[key] = [] }) do |((time, user_id), _), hash|
      case group_by
      when :day
        time = time.strftime('%-d %B %Y')
      when :week
        time = GroupRecords.transform_date_to_week_range(time)
      when :month
        time = time.strftime('%B %Y')
      end
      hash[time].push(user_id)
    end
  end

  private_class_method :sort_active_users_by_time_asc, :format_active_user_times
end
