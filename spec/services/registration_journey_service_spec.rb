# spec/services/registration_journey_service_spec.rb
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RegistrationJourneyService, type: :service do
  describe '.register_interest_events_timeline' do
    it 'builds timeline rows from the registration journey events' do
      interest = FactoryBot.create(:interest)
      visit = FactoryBot.create(:ahoy_visit)
      time = Time.zone.now

      event1 = FactoryBot.create(
        :ahoy_event,
        name: Metrics::LandingPageMetrics::AHOY_EVENT_NAMES[:VISITED_LANDING_PAGE],
        visit: visit,
        time: time - 15.minutes
      )

      event2 = FactoryBot.create(
        :ahoy_event,
        name: Metrics::LandingPageMetrics::AHOY_EVENT_NAMES[:VIEWED_FREE_PLAN_PRICING_OPTION],
        visit: visit,
        time: time - 10.minutes
      )

      event3 = FactoryBot.create(
        :ahoy_event,
        name: Metrics::LandingPageMetrics::AHOY_EVENT_NAMES[:VIEWED_TASK_BREAKDOWN_AI_FEATURE],
        visit: visit,
        time: time - 8.minutes
      )

      registration_event = FactoryBot.create(
        :ahoy_event,
        name: Metrics::LandingPageMetrics::AHOY_EVENT_NAMES[:REGISTERED_INTEREST],
        visit: visit,
        time: time - 5.minutes,
        properties: { 'registration_email' => interest.email }
      )

      FactoryBot.create(
        :ahoy_event,
        name: Metrics::UserGrowthMetrics::AHOY_EVENT_NAMES[:USER_SIGNED_IN_PREFIX],
        visit: visit,
        time: time - 1.minute
      )

      timeline = described_class.register_interest_events_timeline(interest.email)
      expect(timeline).to eq(
        [
          [event1.name, event1.time, event2.time],
          [event2.name, event2.time, event3.time],
          [event3.name, event3.time, registration_event.time],
          [registration_event.name, registration_event.time, registration_event.time + 5.seconds]
        ]
      )
    end
  end
end
