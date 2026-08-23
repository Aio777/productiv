# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Metrics::LandingPageMetrics do
  describe '.calculate_bounce_rate' do
    it 'returns 60.0% for 5 users who visit the landing page, with three users bouncing and two users not bouncing' do
      FactoryBot.create(:visit_with_events)
      FactoryBot.create(:visit_with_events)
      FactoryBot.create(:visit_with_events)

      FactoryBot.create(:visit_with_events, non_landing_page_visit_events: 2)
      FactoryBot.create(:visit_with_events, non_landing_page_visit_events: 3)

      expect(described_class.calculate_bounce_rate).to eq '60.0%'
    end

    it 'return nil for no visits to any page' do
      expect(described_class.calculate_bounce_rate).to be_nil
    end

    it 'returns nil for no visits to just the landing page' do
      FactoryBot.create(:visit_with_events, landing_page_visit_events: 0, non_landing_page_visit_events: 1)
      FactoryBot.create(:visit_with_events, landing_page_visit_events: 0, non_landing_page_visit_events: 3)
      FactoryBot.create(:visit_with_events, landing_page_visit_events: 0, non_landing_page_visit_events: 4)

      expect(described_class.calculate_bounce_rate).to be_nil
    end

    it 'returns 100.0% for a user who repeatedly visits the landing page' do
      FactoryBot.create(:visit_with_events, landing_page_visit_events: 6)

      expect(described_class.calculate_bounce_rate).to eq '100.0%'
    end
  end

  describe '.calculate_traffic_media' do
    it 'returns correct data for users who have visited the app from a variety of channels' do
      FactoryBot.create_list(:ahoy_visit, 3, utm_medium: 'Word of Mouth')
      FactoryBot.create_list(:ahoy_visit, 1, utm_medium: 'Social Media')
      FactoryBot.create_list(:ahoy_visit, 5, utm_medium: 'Sponsorship')
      FactoryBot.create_list(:ahoy_visit, 1, utm_medium: 'Flyer')

      expect(described_class.calculate_traffic_media).to eq(
        { 'Word of Mouth' => '30.0%', 'Social Media' => '10.0%', 'Sponsorship' => '50.0%', 'Flyer' => '10.0%' }
      )
    end

    it 'returns no data when no users have visited the app' do
      expect(described_class.calculate_traffic_media).to eq({})
    end

    it 'returns correct data for users who have visited the app from a single channel' do
      FactoryBot.create_list(:ahoy_visit, 10, utm_medium: 'Sponsorship')

      expect(described_class.calculate_traffic_media).to eq({ 'Sponsorship' => '100.0%' })
    end
  end

  describe '.calculate_traffic_sources' do
    it 'returns correct data for users who have visited the app from a variety of sources' do
      FactoryBot.create_list(:ahoy_visit, 3, utm_source: 'Direct')
      FactoryBot.create_list(:ahoy_visit, 2, utm_source: 'Instagram')
      FactoryBot.create_list(:ahoy_visit, 1, utm_source: 'YouTube')
      FactoryBot.create_list(:ahoy_visit, 3, utm_source: 'TikTok')
      FactoryBot.create_list(:ahoy_visit, 1, utm_source: 'The Diamond - Study Rooms')

      expect(described_class.calculate_traffic_sources).to eq(
        {
          'Direct' => '30.0%',
          'Instagram' => '20.0%',
          'YouTube' => '10.0%',
          'TikTok' => '30.0%',
          'The Diamond - Study Rooms' => '10.0%'
        }
      )
    end

    it 'returns no data when no users have visited the app' do
      expect(described_class.calculate_traffic_sources).to eq({})
    end

    it 'returns correct data for users who have visited the app from a single source' do
      FactoryBot.create_list(:ahoy_visit, 4, utm_source: 'Instagram')

      expect(described_class.calculate_traffic_sources).to eq({ 'Instagram' => '100.0%' })
    end
  end

  describe '.landing_page_visits_over_time' do
    it 'returns correct data for no landing page visits recorded' do
      FactoryBot.create(
        :visit_with_events,
        landing_page_visit_events: 0,
        non_landing_page_visit_events: 1,
        landing_page_event_times: [1.days.ago]
      )

      result = described_class.landing_page_visits_over_time(2.days.ago, :month)

      expect(result.values.sum).to eq(0)
    end

    it 'returns correct data for landing page visits on the same day' do
      FactoryBot.create(
        :visit_with_events,
        landing_page_visit_events: 3,
        non_landing_page_visit_events: 0,
        landing_page_event_times: [1.days.ago, 1.days.ago, 3.days.ago]
      )

      result = described_class.landing_page_visits_over_time(2.days.ago, :month)

      expect(result.values.sum).to eq(2)
    end

    it 'returns correct data for landing page visits over a time range of 7 days' do
      FactoryBot.create(
        :visit_with_events,
        landing_page_visit_events: 4,
        non_landing_page_visit_events: 0,
        landing_page_event_times: [1.days.ago, 5.days.ago, 8.days.ago, 11.days.ago]
      )

      result = described_class.landing_page_visits_over_time(7.days.ago, :month)

      expect(result.values.sum).to eq(2)
    end

    it 'returns correct data for landing page visits over a time range of 1 month' do
      FactoryBot.create(
        :visit_with_events,
        landing_page_visit_events: 4,
        non_landing_page_visit_events: 0,
        landing_page_event_times: [1.days.ago, 5.days.ago, 15.days.ago, 32.days.ago]
      )

      result = described_class.landing_page_visits_over_time(1.month.ago, :month)

      expect(result.values.sum).to eq(3)
    end

    it 'returns correct data for landing page visits that occur on the time boundary' do
      FactoryBot.create(
        :visit_with_events,
        landing_page_visit_events: 1,
        non_landing_page_visit_events: 0,
        landing_page_event_times: [2.days.ago]
      )

      result = described_class.landing_page_visits_over_time(2.days.ago, :month)

      expect(result.values.sum).to eq(0)
    end
  end

  describe '.registrations_over_time' do
    it 'returns correct data for no registrations recorded' do
      result = described_class.registrations_over_time(2.days.ago, :month)

      expect(result.values.sum).to eq(0)
    end

    it 'returns correct data for customer registrations recorded on the same day' do
      Interest.create!(name: 'register1', email: 'email1@example.com', created_at: 1.days.ago)
      Interest.create!(name: 'register2', email: 'email2@example.com', created_at: 1.days.ago)
      Interest.create!(name: 'register3', email: 'email3@example.com', created_at: 3.days.ago)

      result = described_class.registrations_over_time(2.days.ago, :month)

      expect(result.values.sum).to eq(2)
    end

    it 'returns correct data for customer registrations recorded over a time frame of 7 days' do
      Interest.create!(name: 'register1', email: 'email1@example.com', created_at: 1.days.ago)
      Interest.create!(name: 'register2', email: 'email2@example.com', created_at: 5.days.ago)
      Interest.create!(name: 'register3', email: 'email3@example.com', created_at: 8.days.ago)

      result = described_class.registrations_over_time(7.days.ago, :month)

      expect(result.values.sum).to eq(2)
    end

    it 'returns correct data for customer registrations recorded over a time frame of 1 month' do
      Interest.create!(name: 'register1', email: 'email1@example.com', created_at: 1.days.ago)
      Interest.create!(name: 'register2', email: 'email2@example.com', created_at: 15.days.ago)
      Interest.create!(name: 'register3', email: 'email3@example.com', created_at: 32.days.ago)

      result = described_class.registrations_over_time(1.month.ago, :month)

      expect(result.values.sum).to eq(2)
    end

    it 'returns correct data for customer registrations recorded on the time boundary' do
      Interest.create!(name: 'register1', email: 'email3@example.com', created_at: 3.days.ago)

      result = described_class.registrations_over_time(3.days.ago, :month)

      expect(result.values.sum).to eq(0)
    end
  end

  describe '.event_locations' do
    it 'returns nil for events that are not landing page visits or registering interest' do
      expect(
        described_class.event_locations(described_class::AHOY_EVENT_NAMES[:OPENED_REGISTER_INTEREST_MODAL])
      ).to be_nil
      expect(
        described_class.event_locations(described_class::AHOY_EVENT_NAMES[:VIEWED_WORKSPACES_AND_PROJECTS_FEATURE])
      ).to be_nil
      expect(described_class.event_locations(described_class::AHOY_EVENT_NAMES[:SHARED_FEATURE_PREFIX])).to be_nil
      expect(
        described_class.event_locations(described_class::AHOY_EVENT_NAMES[:VIEWED_FREE_PLAN_PRICING_OPTION])
      ).to be_nil
      expect(described_class.event_locations(described_class::AHOY_EVENT_NAMES[:OPENED_LEAVE_REVIEW_MODAL])).to be_nil
      expect(described_class.event_locations(described_class::AHOY_EVENT_NAMES[:VIEWED_QUESTION_PREFIX])).to be_nil
      expect(described_class.event_locations(described_class::AHOY_EVENT_NAMES[:POSTED_QUESTION])).to be_nil

      expect(described_class.event_locations(described_class::AHOY_EVENT_NAMES[:VISITED_LANDING_PAGE])).not_to be_nil
      expect(described_class.event_locations(described_class::AHOY_EVENT_NAMES[:REGISTERED_INTEREST])).not_to be_nil
    end

    it 'returns the correct locations for landing page visits' do
      FactoryBot.create_list(:ahoy_event, 3, name: described_class::AHOY_EVENT_NAMES[:VISITED_LANDING_PAGE],
                                             properties: { country: 'United Kingdom', city: 'Sheffield' })
      FactoryBot.create_list(:ahoy_event, 6, name: described_class::AHOY_EVENT_NAMES[:VISITED_LANDING_PAGE],
                                             properties: { country: 'United Kingdom', city: 'London' })
      FactoryBot.create_list(:ahoy_event, 2, name: described_class::AHOY_EVENT_NAMES[:VISITED_LANDING_PAGE],
                                             properties: { country: 'Sweden', city: 'Stockholm' })
      FactoryBot.create_list(:ahoy_event, 1, name: described_class::AHOY_EVENT_NAMES[:VISITED_LANDING_PAGE],
                                             properties: { country: 'India', city: 'Mumbai' })

      expect(described_class.event_locations(described_class::AHOY_EVENT_NAMES[:VISITED_LANDING_PAGE])).to eq(
        { { country: 'United Kingdom', city: 'Sheffield' } => 3, { country: 'United Kingdom', city: 'London' } => 6,
          { country: 'Sweden', city: 'Stockholm' } => 2, { country: 'India', city: 'Mumbai' } => 1 }
      )
    end

    it 'returns the correct locations for registering interest' do
      FactoryBot.create_list(:ahoy_event, 3, name: described_class::AHOY_EVENT_NAMES[:REGISTERED_INTEREST],
                                             properties: { country: 'United Kingdom', city: 'Sheffield' })
      FactoryBot.create_list(:ahoy_event, 6, name: described_class::AHOY_EVENT_NAMES[:REGISTERED_INTEREST],
                                             properties: { country: 'United Kingdom', city: 'London' })
      FactoryBot.create_list(:ahoy_event, 2, name: described_class::AHOY_EVENT_NAMES[:REGISTERED_INTEREST],
                                             properties: { country: 'Sweden', city: 'Stockholm' })
      FactoryBot.create_list(:ahoy_event, 1, name: described_class::AHOY_EVENT_NAMES[:REGISTERED_INTEREST],
                                             properties: { country: 'India', city: 'Mumbai' })

      expect(described_class.event_locations(described_class::AHOY_EVENT_NAMES[:REGISTERED_INTEREST])).to eq(
        { { country: 'United Kingdom', city: 'Sheffield' } => 3, { country: 'United Kingdom', city: 'London' } => 6,
          { country: 'Sweden', city: 'Stockholm' } => 2, { country: 'India', city: 'Mumbai' } => 1 }
      )
    end
  end

  describe '.views_of_each_feature' do
    it 'returns nothing when there are no feature views' do
      expect(described_class.views_of_each_feature).to eq({})
    end

    it 'returns valid data for feature views' do
      FactoryBot.create_list(:ahoy_event, 2, name: described_class::AHOY_EVENT_NAMES[:VIEWED_TASK_BREAKDOWN_AI_FEATURE])
      FactoryBot.create_list(:ahoy_event, 4, name: described_class::AHOY_EVENT_NAMES[:VIEWED_PROGRESS_REWARDED_FEATURE])
      FactoryBot.create_list(:ahoy_event, 1, name: described_class::AHOY_EVENT_NAMES[:VIEWED_VIRTUAL_PLANT_FEATURE])

      expect(described_class.views_of_each_feature).to eq(
        { 'Task Breakdown Assistance with AI' => 2, 'Be Rewarded for Progress' => 4, 'Your Virtual Plant' => 1 }
      )
    end
  end

  describe '.views_of_each_pricing_option' do
    it 'returns nothing when there are no pricing option views' do
      expect(described_class.views_of_each_pricing_option).to eq({})
    end

    it 'returns valid data for pricing option views' do
      FactoryBot.create_list(:ahoy_event, 3,
                             name: described_class::AHOY_EVENT_NAMES[:VIEWED_FREE_PLAN_PRICING_OPTION])
      FactoryBot.create_list(:ahoy_event, 5,
                             name: described_class::AHOY_EVENT_NAMES[:VIEWED_MONTHLY_PLAN_PRICING_OPTION])
      FactoryBot.create_list(:ahoy_event, 2,
                             name: described_class::AHOY_EVENT_NAMES[:VIEWED_ANNUAL_PLAN_PRICING_OPTION])

      expect(described_class.views_of_each_pricing_option).to eq(
        { 'Free Plan' => 3, 'Monthly Plan' => 5, 'Annual Plan' => 2 }
      )
    end
  end

  describe '.feature_shares' do
    it 'returns nothing when there are no feature shares' do
      expect(described_class.feature_shares).to eq({})
    end

    it 'returns valid data for feature shares' do
      FactoryBot.create_list(:ahoy_event, 1, name: "Shared Feature '#{
        described_class::AHOY_EVENT_NAMES[:VIEWED_WORKSPACES_AND_PROJECTS_FEATURE]
      }'")
      FactoryBot.create_list(:ahoy_event, 5, name: "Shared Feature '#{
        described_class::AHOY_EVENT_NAMES[:VIEWED_PROGRESS_VISUALISATION_FEATURE]
      }'")
      FactoryBot.create_list(:ahoy_event, 2, name: "Shared Feature '#{
        described_class::AHOY_EVENT_NAMES[:VIEWED_PROGRESS_REWARDED_FEATURE]
      }'")
      FactoryBot.create_list(:ahoy_event, 2, name: "Shared Feature '#{
        described_class::AHOY_EVENT_NAMES[:VIEWED_LEADERBOARDS_FEATURE]
      }'")
      FactoryBot.create_list(:ahoy_event, 1, name: "Shared Feature '#{
        described_class::AHOY_EVENT_NAMES[:VIEWED_VIRTUAL_PLANT_FEATURE]
      }'")

      expect(described_class.feature_shares).to eq(
        { "Shared Feature 'Workspaces & Projects'" => 1, "Shared Feature 'Progress Visualisation'" => 5,
          "Shared Feature 'Be Rewarded for Progress'" => 2, "Shared Feature 'Leaderboards'" => 2,
          "Shared Feature 'Your Virtual Plant'" => 1 }
      )
    end
  end

  describe '.landing_page_metrics' do
    it 'returns the correct metric data' do
      expect(described_class.landing_page_metrics(:day, :day)).to eq(
        { bounce_rate:
          { title: 'Bounce Rate', label: 'Bounced %', value: { 'Bounce Rate' => 'None' }.to_json, continuous: false,
            time_unit: nil },
          traffic_media:
          { title: 'Traffic Media', label: 'Traffic %', values: {}.to_json, continuous: false, time_unit: nil },
          traffic_sources:
          { title: 'Traffic Sources', label: 'Traffic %', values: {}.to_json, continuous: false, time_unit: nil },
          visit_times:
          { title: 'Visit Times By Day', label: 'Visits', values: {}.to_json, continuous: true, time_unit: 'day' },
          visit_locations:
          { title: 'Visit Locations', label: 'Visits', values: {}.to_json, continuous: false, time_unit: nil },
          registration_times:
          { title: 'Registration Times By Day', label: 'Registrations', values: {}.to_json, continuous: true,
            time_unit: 'day' },
          registration_locations:
          { title: 'Registration Locations', label: 'Registrations', values: {}.to_json, continuous: false,
            time_unit: nil },
          pricing_views:
          { title: 'Pricing Views', label: 'Views', values: {}.to_json, continuous: false, time_unit: nil },
          feature_views:
          { title: 'Feature Views', label: 'Views', values: {}.to_json, continuous: false, time_unit: nil },
          shared_features:
          { title: 'Feature Shares', label: 'Shares', values: {}.to_json, continuous: false, time_unit: nil } }
      )
    end
  end
end
