# frozen_string_literal: true

# == Schema Information
#
# Table name: ahoy_visits
#
#  id               :bigint           not null, primary key
#  app_version      :string
#  browser          :string
#  city             :string
#  country          :string
#  device_type      :string
#  ip               :string
#  landing_page     :text
#  latitude         :float
#  longitude        :float
#  os               :string
#  os_version       :string
#  platform         :string
#  referrer         :text
#  referring_domain :string
#  region           :string
#  started_at       :datetime
#  user_agent       :text
#  utm_campaign     :string
#  utm_content      :string
#  utm_medium       :string
#  utm_source       :string
#  utm_term         :string
#  visit_token      :string
#  visitor_token    :string
#  user_id          :bigint
#
# Indexes
#
#  index_ahoy_visits_on_user_id                       (user_id)
#  index_ahoy_visits_on_visit_token                   (visit_token) UNIQUE
#  index_ahoy_visits_on_visitor_token_and_started_at  (visitor_token,started_at)
#
FactoryBot.define do
  factory :ahoy_event, class: 'Ahoy::Event' do
    association :visit, factory: :ahoy_visit
    time { Time.current}
  end

  factory :ahoy_visit, class: 'Ahoy::Visit' do
    factory :visit_with_events, class: 'Ahoy::Visit' do
      transient do
        landing_page_visit_events { 1 }
        non_landing_page_visit_events { 0 }

        landing_page_event_times{ [] }
      end

      after(:create) do |visit, context|
        create_list(
          :ahoy_event,
          context.landing_page_visit_events,
          name: Metrics::LandingPageMetrics::AHOY_EVENT_NAMES[:VISITED_LANDING_PAGE],
          visit: visit
        ).each_with_index do |event, i|
          event.update!(time: context.landing_page_event_times[i]) if context.landing_page_event_times[i]
        end

        create_list(:ahoy_event, context.non_landing_page_visit_events,
                    name: Metrics::UserGrowthMetrics::AHOY_EVENT_NAMES[:USER_SIGNED_IN_PREFIX], visit: visit)

        visit.reload
      end
    end
  end
end
