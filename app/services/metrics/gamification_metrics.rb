# frozen_string_literal: true

# Module containing methods to be used by product owners to track engagement for the different gamification components
module Metrics::GamificationMetrics
  AHOY_EVENT_NAMES = {
    EARNED_POINTS_FROM_INDIVIDUAL_TASK_PREFIX: 'Points from Individual Task',
    EARNED_POINTS_FROM_SHARED_TASK_PREFIX: 'Points from Shared Task',

    PURCHASED_ITEM_PREFIX: 'Purchased Item',

    PLANT_BROUGHT_TO_LIFE_PREFIX: 'Brought to Life',
    PLANT_REVIVED_FROM_DEATH_PREFIX: 'Revived From Death',
    PLANT_DIED_PREFIX: 'Died'
  }.freeze

  def self.shop_purchases_per_week
    shop_purchase_events = Ahoy::Event.where('name LIKE ?', "%#{AHOY_EVENT_NAMES[:PURCHASED_ITEM_PREFIX]}%")

    GroupRecords.group_records_by_time(shop_purchase_events, :time, nil, :week)
  end

  def self.points_earned_per_user_per_week
    user_earned_points_per_week = Ahoy::Event.where('name LIKE ?', "%#{
      AHOY_EVENT_NAMES[:EARNED_POINTS_FROM_INDIVIDUAL_TASK_PREFIX]
    }%").or(
      Ahoy::Event.where('name LIKE ?', "%#{
        AHOY_EVENT_NAMES[:EARNED_POINTS_FROM_SHARED_TASK_PREFIX]
      }%")
    ).group(:user_id).group_by_week(:time, week_start: :monday, series: false).sum("(properties->>'task_points')::int")

    user_earned_points_per_week.each_with_object(
      Hash.new { |hash, key| hash[key] = {} }
    ) do |((user_id, week), points), hash|
      email = User.find(user_id).email
      week = GroupRecords.transform_date_to_week_range(week)
      hash[email][week] = points
    end
  end

  def self.plants_died_per_week
    plant_death_events = Ahoy::Event.where('name LIKE ?', "%#{AHOY_EVENT_NAMES[:PLANT_DIED_PREFIX]}")

    GroupRecords.group_records_by_time(plant_death_events, :time, nil, :week)
  end

  def self.average_plant_streak_length
    average_plant_streaks = []

    User.includes(:plant).where(role: 'subscriber').each do |subscriber|
      average_plant_streak = Poro::Plant.new(subscriber.plant).calculate_average_plant_streak
      average_plant_streaks.push(average_plant_streak) unless average_plant_streak.nil?
    end

    return nil if average_plant_streaks.empty?

    average_plant_streak = average_plant_streaks.inject do |sum, average_plant_streak|
      sum + average_plant_streak
    end.to_f / average_plant_streaks.size

    ActiveSupport::Duration.build(average_plant_streak.round).inspect
  end

  def self.gamification_metrics
    gamification_metrics = {}

    gamification_metrics[:shop_purchases] =
      { title: 'Shop Purchases By Week', label: 'Purchases', values: shop_purchases_per_week.to_json, continuous: true,
        time_unit: 'week' }

    gamification_metrics[:points_earned_per_user] =
      { title: 'Points Earned Per User By Week', label: 'Points', values: points_earned_per_user_per_week.to_json,
        continuous: true, time_unit: 'week' }

    gamification_metrics[:plants_died] =
      { title: 'Plant Deaths By Week', label: 'Plant Deaths', values: plants_died_per_week.to_json, continuous: true,
        time_unit: 'week' }

    average_plant_streak = if average_plant_streak_length.nil?
                             'None'
                           else
                             average_plant_streak_length
                           end

    gamification_metrics[:average_plant_streak] =
      { title: 'Average Plant Streak Time', label: ['Average Plant Streak'], values: [average_plant_streak],
        continuous: false, time_unit: nil }

    gamification_metrics
  end
end
