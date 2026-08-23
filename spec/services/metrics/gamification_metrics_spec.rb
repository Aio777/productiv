# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Metrics::GamificationMetrics do
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
    it '.shop_purchases_per_week returns the correct number of shop purchases' do
      create_events_single_week("User #%<user_id>s #{
        Metrics::GamificationMetrics::AHOY_EVENT_NAMES[:PURCHASED_ITEM_PREFIX]
      }")

      expect(described_class.shop_purchases_per_week.count).to eq(1)
      expect(described_class.shop_purchases_per_week.value?(12)).to be true
    end

    it '.points_earned_per_user_per_week returns the correct number of points per user' do
      earned_points_from_individual_task = "User #%<user_id>s Earned %<task_points>s #{
        Metrics::GamificationMetrics::AHOY_EVENT_NAMES[:EARNED_POINTS_FROM_INDIVIDUAL_TASK_PREFIX]
      } ##{rand(1..100)}"
      earned_points_from_shared_task = "User #%<user_id>s Earned %<task_points>s #{
        Metrics::GamificationMetrics::AHOY_EVENT_NAMES[:EARNED_POINTS_FROM_INDIVIDUAL_TASK_PREFIX]
      } ##{rand(1..100)}"

      FactoryBot.create_list(
        :ahoy_event,
        5,
        user: current_user,
        name: format(earned_points_from_individual_task, user_id: current_user.id, task_points: '10'),
        properties: { task_points: '10' }
      )
      FactoryBot.create_list(
        :ahoy_event,
        3,
        user: current_user,
        name: format(earned_points_from_shared_task, user_id: current_user.id, task_points: '5'),
        properties: { task_points: '5' }
      )
      FactoryBot.create_list(
        :ahoy_event,
        1,
        user: other_user1,
        name: format(earned_points_from_individual_task, user_id: other_user1.id, task_points: '20'),
        properties: { task_points: '20' }
      )
      FactoryBot.create_list(
        :ahoy_event,
        3,
        user: other_user2,
        name: format(earned_points_from_shared_task, user_id: other_user2.id, task_points: '50'),
        properties: { task_points: '50' }
      )
      FactoryBot.create_list(
        :ahoy_event,
        6,
        user: other_user2,
        name: format(earned_points_from_shared_task, user_id: other_user2.id, task_points: '1'),
        properties: { task_points: '5' }
      )

      expect(Set.new(described_class.points_earned_per_user_per_week.keys)).to eq(
        Set[current_user.email, other_user1.email, other_user2.email]
      )
      expect(described_class.points_earned_per_user_per_week[current_user.email].count).to eq(1)
      expect(described_class.points_earned_per_user_per_week[current_user.email].value?(65)).to be true

      expect(described_class.points_earned_per_user_per_week[other_user1.email].count).to eq(1)
      expect(described_class.points_earned_per_user_per_week[other_user1.email].value?(20)).to be true

      expect(described_class.points_earned_per_user_per_week[other_user2.email].count).to eq(1)
      expect(described_class.points_earned_per_user_per_week[other_user2.email].value?(180)).to be true
    end

    it '.plants_died_per_week returns the correct number of plant deaths' do
      create_events_single_week("Plant ##{rand(1..100)} From User #%<user_id>s #{
        Metrics::GamificationMetrics::AHOY_EVENT_NAMES[:PLANT_DIED_PREFIX]
      }")

      expect(described_class.plants_died_per_week.count).to eq(1)
      expect(described_class.plants_died_per_week.value?(12)).to be true
    end
  end

  context 'when looking across several weeks,' do
    it '.shop_purchases_per_week returns the correct number of shop purchases' do
      create_events_several_weeks("User #%<user_id>s #{
        Metrics::GamificationMetrics::AHOY_EVENT_NAMES[:PURCHASED_ITEM_PREFIX]
      }")

      expect(described_class.shop_purchases_per_week.count).to eq(3)
      expect(Set.new(described_class.shop_purchases_per_week.values)).to eq(Set[5, 3, 4])
    end

    it '.points_earned_per_user_per_week returns the correct number of points per user' do
      earned_points_from_individual_task = "User #%<user_id>s Earned %<task_points>s #{
        Metrics::GamificationMetrics::AHOY_EVENT_NAMES[:EARNED_POINTS_FROM_INDIVIDUAL_TASK_PREFIX]
      } ##{rand(1..100)}"
      earned_points_from_shared_task = "User #%<user_id>s Earned %<task_points>s #{
        Metrics::GamificationMetrics::AHOY_EVENT_NAMES[:EARNED_POINTS_FROM_INDIVIDUAL_TASK_PREFIX]
      } ##{rand(1..100)}"

      FactoryBot.create_list(
        :ahoy_event,
        5,
        user: current_user,
        name: format(earned_points_from_individual_task, user_id: current_user.id, task_points: '10'),
        properties: { task_points: '10' }
      )
      FactoryBot.create_list(
        :ahoy_event,
        3,
        user: current_user,
        name: format(earned_points_from_shared_task, user_id: current_user.id, task_points: '5'),
        properties: { task_points: '5' },
        time: 2.weeks.ago
      )
      FactoryBot.create_list(
        :ahoy_event,
        1,
        user: other_user1,
        name: format(earned_points_from_individual_task, user_id: other_user1.id, task_points: '20'),
        properties: { task_points: '20' },
        time: 2.weeks.ago
      )
      FactoryBot.create_list(
        :ahoy_event,
        3,
        user: other_user2,
        name: format(earned_points_from_shared_task, user_id: other_user2.id, task_points: '50'),
        properties: { task_points: '50' },
        time: 1.week.ago
      )
      FactoryBot.create_list(
        :ahoy_event,
        6,
        user: other_user2,
        name: format(earned_points_from_shared_task, user_id: other_user2.id, task_points: '1'),
        properties: { task_points: '5' },
        time: 1.month.ago
      )

      expect(Set.new(described_class.points_earned_per_user_per_week.keys)).to eq(
        Set[current_user.email, other_user1.email, other_user2.email]
      )
      expect(Set.new(described_class.points_earned_per_user_per_week[current_user.email].values)).to eq(
        Set[50, 15]
      )
      expect(Set.new(described_class.points_earned_per_user_per_week[other_user1.email].values)).to eq(
        Set[20]
      )
      expect(Set.new(described_class.points_earned_per_user_per_week[other_user2.email].values)).to eq(
        Set[150, 30]
      )
    end

    it '.plants_died_per_week returns the correct number of plant deaths' do
      create_events_several_weeks("Plant ##{rand(1..100)} From User #%<user_id>s #{
        Metrics::GamificationMetrics::AHOY_EVENT_NAMES[:PLANT_DIED_PREFIX]
      }")

      expect(described_class.plants_died_per_week.count).to eq(3)
      expect(Set.new(described_class.plants_died_per_week.values)).to eq(Set[5, 3, 4])
    end
  end

  describe '.average_plant_streak_length' do
    it 'returns the correct plant streak length for one subscriber' do
      time = Time.zone.local(2026, 1, 1, 0, 0, 0)

      FactoryBot.create(
        :ahoy_event,
        user: current_user,
        name: "Plant ##{current_user.plant.id} From User ##{current_user.id} #{
          Metrics::GamificationMetrics::AHOY_EVENT_NAMES[:PLANT_BROUGHT_TO_LIFE_PREFIX]
        }",
        time: time
      )
      FactoryBot.create(
        :ahoy_event,
        user: current_user,
        name: "Plant ##{current_user.plant.id} From User ##{current_user.id} #{
          Metrics::GamificationMetrics::AHOY_EVENT_NAMES[:PLANT_DIED_PREFIX]
        }",
        time: time + 1.week
      )

      FactoryBot.create(
        :ahoy_event,
        user: current_user,
        name: "Plant ##{current_user.plant.id} From User ##{current_user.id} #{
          Metrics::GamificationMetrics::AHOY_EVENT_NAMES[:PLANT_REVIVED_FROM_DEATH_PREFIX]
        }",
        time: time + 1.month
      )
      FactoryBot.create(
        :ahoy_event,
        user: current_user,
        name: "Plant ##{current_user.plant.id} From User ##{current_user.id} #{
          Metrics::GamificationMetrics::AHOY_EVENT_NAMES[:PLANT_DIED_PREFIX]
        }",
        time: time + 1.month + 3.weeks
      )

      expect(described_class.average_plant_streak_length).to eq('2 weeks')
    end

    it 'returns the correct plant streak length for multiple subscribers' do
      time = Time.zone.local(2026, 1, 1, 0, 0, 0)

      FactoryBot.create(
        :ahoy_event,
        user: current_user,
        name: "Plant ##{current_user.plant.id} From User ##{current_user.id} #{
          Metrics::GamificationMetrics::AHOY_EVENT_NAMES[:PLANT_BROUGHT_TO_LIFE_PREFIX]
        }",
        time: time
      )
      FactoryBot.create(
        :ahoy_event,
        user: current_user,
        name: "Plant ##{current_user.plant.id} From User ##{current_user.id} #{
          Metrics::GamificationMetrics::AHOY_EVENT_NAMES[:PLANT_DIED_PREFIX]
        }",
        time: time + 1.day
      )

      FactoryBot.create(
        :ahoy_event,
        user: current_user,
        name: "Plant ##{current_user.plant.id} From User ##{current_user.id} #{
          Metrics::GamificationMetrics::AHOY_EVENT_NAMES[:PLANT_REVIVED_FROM_DEATH_PREFIX]
        }",
        time: time + 1.week
      )
      FactoryBot.create(
        :ahoy_event,
        user: current_user,
        name: "Plant ##{current_user.plant.id} From User ##{current_user.id} #{
          Metrics::GamificationMetrics::AHOY_EVENT_NAMES[:PLANT_DIED_PREFIX]
        }",
        time: time + 1.week + 5.days
      )

      FactoryBot.create(
        :ahoy_event,
        user: other_user1,
        name: "Plant ##{other_user1.plant.id} From User ##{other_user1.id} #{
          Metrics::GamificationMetrics::AHOY_EVENT_NAMES[:PLANT_BROUGHT_TO_LIFE_PREFIX]
        }",
        time: time + 1.month
      )
      FactoryBot.create(
        :ahoy_event,
        user: other_user1,
        name: "Plant ##{other_user1.plant.id} From User ##{other_user1.id} #{
          Metrics::GamificationMetrics::AHOY_EVENT_NAMES[:PLANT_DIED_PREFIX]
        }",
        time: time + 1.month + 1.week
      )

      expect(described_class.average_plant_streak_length).to eq('5 days')
    end
  end

  describe '.gamification_metrics' do
    it 'returns the correct metric data' do
      expect(described_class.gamification_metrics).to eq(
        { shop_purchases:
          { title: 'Shop Purchases By Week', label: 'Purchases', values: {}.to_json, continuous: true,
            time_unit: 'week' },
          points_earned_per_user:
          { title: 'Points Earned Per User By Week', label: 'Points', values: {}.to_json, continuous: true,
            time_unit: 'week' },
          plants_died:
          { title: 'Plant Deaths By Week', label: 'Plant Deaths', values: {}.to_json, continuous: true,
            time_unit: 'week' },
          average_plant_streak:
          { title: 'Average Plant Streak Time', label: ['Average Plant Streak'], values: ['None'], continuous: false,
            time_unit: nil } }
      )
    end
  end
end
