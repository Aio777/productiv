# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Metrics::UserGrowthMetrics do
  describe '.active_users' do
    let(:current_user) { FactoryBot.create(:user, role: 'subscriber') }
    let(:other_user1) { FactoryBot.create(:user, role: 'subscriber') }
    let(:other_user2) { FactoryBot.create(:user, role: 'subscriber') }

    before do
      time = Time.zone.local(2026, 1, 1, 0, 0, 0)

      FactoryBot.create(
        :ahoy_event,
        user: current_user,
        name: "User ##{current_user.id} #{Metrics::UserGrowthMetrics::AHOY_EVENT_NAMES[:USER_SIGNED_IN_PREFIX]}",
        time: time
      )
      FactoryBot.create(
        :ahoy_event,
        user: current_user,
        name: "User ##{current_user.id} #{Metrics::UserGrowthMetrics::AHOY_EVENT_NAMES[:USER_SIGNED_IN_PREFIX]}",
        time: time + 1.day
      )
      FactoryBot.create(
        :ahoy_event,
        user: current_user,
        name: "User ##{current_user.id} #{Metrics::UserGrowthMetrics::AHOY_EVENT_NAMES[:USER_SIGNED_IN_PREFIX]}",
        time: time + 1.day
      )
      FactoryBot.create(
        :ahoy_event,
        user: current_user,
        name: "User ##{current_user.id} #{Metrics::UserGrowthMetrics::AHOY_EVENT_NAMES[:USER_SIGNED_IN_PREFIX]}",
        time: time + 1.week
      )

      FactoryBot.create(
        :ahoy_event,
        user: other_user1,
        name: "User ##{other_user1.id} #{Metrics::UserGrowthMetrics::AHOY_EVENT_NAMES[:USER_SIGNED_IN_PREFIX]}",
        time: time
      )
      FactoryBot.create(
        :ahoy_event,
        user: other_user1,
        name: "User ##{other_user1.id} #{Metrics::UserGrowthMetrics::AHOY_EVENT_NAMES[:USER_SIGNED_IN_PREFIX]}",
        time: time + 2.days
      )
      FactoryBot.create(
        :ahoy_event,
        user: other_user1,
        name: "User ##{other_user1.id} #{Metrics::UserGrowthMetrics::AHOY_EVENT_NAMES[:USER_SIGNED_IN_PREFIX]}",
        time: time + 2.months
      )

      FactoryBot.create(
        :ahoy_event,
        user: other_user2,
        name: "User ##{other_user2.id} #{Metrics::UserGrowthMetrics::AHOY_EVENT_NAMES[:USER_SIGNED_IN_PREFIX]}",
        time: time
      )
      FactoryBot.create(
        :ahoy_event,
        user: other_user2,
        name: "User ##{other_user2.id} #{Metrics::UserGrowthMetrics::AHOY_EVENT_NAMES[:USER_SIGNED_IN_PREFIX]}",
        time: time + 1.month
      )
      FactoryBot.create(
        :ahoy_event,
        user: other_user2,
        name: "User ##{other_user2.id} #{Metrics::UserGrowthMetrics::AHOY_EVENT_NAMES[:USER_SIGNED_IN_PREFIX]}",
        time: time + 2.months
      )
      FactoryBot.create(
        :ahoy_event,
        user: other_user2,
        name: "User ##{other_user2.id} #{Metrics::UserGrowthMetrics::AHOY_EVENT_NAMES[:USER_SIGNED_IN_PREFIX]}",
        time: time + 2.months + 1.week
      )
      FactoryBot.create(
        :ahoy_event,
        user: other_user2,
        name: "User ##{other_user2.id} #{Metrics::UserGrowthMetrics::AHOY_EVENT_NAMES[:USER_SIGNED_IN_PREFIX]}",
        time: time + 2.months + 1.week + 1.day
      )
    end

    it 'correctly returns active users by day' do
      expect(described_class.active_users(:day)).to eq(
        {
          '1 January 2026' => 3,
          '2 January 2026' => 1,
          '3 January 2026' => 1,
          '8 January 2026' => 1,
          '1 February 2026' => 1,
          '1 March 2026' => 2,
          '8 March 2026' => 1,
          '9 March 2026' => 1
        }
      )
    end

    it 'correctly returns active users by week' do
      expect(described_class.active_users(:week)).to eq(
        {
          '29 Dec 2025 - 4 Jan 2026' => 3,
          '26 Jan 2026 - 1 Feb 2026' => 1,
          '23 Feb 2026 - 1 Mar 2026' => 2,
          '2 Mar 2026 - 8 Mar 2026' => 1,
          '9 Mar 2026 - 15 Mar 2026' => 1,
          '5 Jan 2026 - 11 Jan 2026' => 1
        }
      )
    end

    it 'correctly returns active users by month' do
      expect(described_class.active_users(:month)).to eq(
        {
          'January 2026' => 3,
          'February 2026' => 1,
          'March 2026' => 2
        }
      )
    end
  end

  describe '.user_growth_metrics' do
    it 'returns the correct metric data' do
      expect(described_class.user_growth_metrics).to eq(
        { daily_active_users:
          { title: 'Active Users By Day', label: 'Active Users', values: {}.to_json, continuous: true,
            time_unit: 'day' },
          weekly_active_users:
          { title: 'Active Users By Week', label: 'Active Users', values: {}.to_json, continuous: true,
            time_unit: 'week' },
          monthly_active_users:
          { title: 'Active Users By Month', label: 'Active Users', values: {}.to_json, continuous: true,
            time_unit: 'month' } }
      )
    end
  end
end
