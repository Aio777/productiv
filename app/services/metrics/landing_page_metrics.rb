# frozen_string_literal: true

# Module containing methods to be used by product owners and reporters to track key metrics for the landing page and for
# the larger application

module Metrics::LandingPageMetrics
  AHOY_EVENT_NAMES = {
    VISITED_LANDING_PAGE: 'Visited Landing Page',

    OPENED_REGISTER_INTEREST_MODAL: "Opened 'Register Interest' Modal",
    REGISTERED_INTEREST: 'Registered Interest',

    VIEWED_TASK_BREAKDOWN_AI_FEATURE: 'Task Breakdown Assistance with AI',
    VIEWED_WORKSPACES_AND_PROJECTS_FEATURE: 'Workspaces & Projects',
    VIEWED_PROGRESS_VISUALISATION_FEATURE: 'Progress Visualisation',
    VIEWED_POMODORO_TIMER_FEATURE: 'Pomodoro Timer',
    VIEWED_PROGRESS_REWARDED_FEATURE: 'Be Rewarded for Progress',
    VIEWED_LEADERBOARDS_FEATURE: 'Leaderboards',
    VIEWED_VIRTUAL_PLANT_FEATURE: 'Your Virtual Plant',

    SHARED_FEATURE_PREFIX: 'Shared Feature',

    VIEWED_FREE_PLAN_PRICING_OPTION: 'Free Plan',
    VIEWED_MONTHLY_PLAN_PRICING_OPTION: 'Monthly Plan',
    VIEWED_ANNUAL_PLAN_PRICING_OPTION: 'Annual Plan',

    OPENED_LEAVE_REVIEW_MODAL: "Opened 'Leave a Review' Modal",

    VIEWED_QUESTION_PREFIX: 'Viewed Question',
    POSTED_QUESTION: 'Posted Question'
  }.freeze

  def self.calculate_bounce_rate
    total_landing_page_visits = Ahoy::Visit
                                .joins(:events)
                                .where(events: { name: AHOY_EVENT_NAMES[:VISITED_LANDING_PAGE] })
                                .distinct
                                .count

    return nil if total_landing_page_visits.zero?

    visits_that_visited_landing_page = Ahoy::Visit
                                       .select(:id)
                                       .joins(:events)
                                       .where(events: { name: AHOY_EVENT_NAMES[:VISITED_LANDING_PAGE] })

    bounced_landing_page_visits = Ahoy::Visit
                                  .joins(:events)
                                  .group(:id)
                                  .having(id: visits_that_visited_landing_page)
                                  .having('COUNT(DISTINCT ahoy_events.name) = 1')
                                  .count
                                  .size

    "#{((bounced_landing_page_visits.to_f / total_landing_page_visits) * 100).round(2)}%"
  end

  def self.calculate_traffic_media
    get_traffic_proportions(:utm_medium)
  end

  def self.calculate_traffic_sources
    get_traffic_proportions(:utm_source)
  end

  def self.landing_page_visits_over_time(time_range = nil, group_by = :month)
    landing_page_visits = Ahoy::Event.where(name: AHOY_EVENT_NAMES[:VISITED_LANDING_PAGE])

    GroupRecords.group_records_by_time(landing_page_visits, :time, time_range, group_by)
  end

  def self.registrations_over_time(time_range = nil, group_by = :month)
    registrations = Interest.all

    GroupRecords.group_records_by_time(registrations, :created_at, time_range, group_by)
  end

  def self.event_locations(event_name)
    unless Set[AHOY_EVENT_NAMES[:VISITED_LANDING_PAGE], AHOY_EVENT_NAMES[:REGISTERED_INTEREST]].include? event_name
      return nil
    end

    events = Ahoy::Event.where(name: event_name)
    get_location_counts_from_events(events)
  end

  def self.views_of_each_feature
    Ahoy::Event.where(name: AHOY_EVENT_NAMES[:VIEWED_TASK_BREAKDOWN_AI_FEATURE])
               .or(Ahoy::Event.where(name: AHOY_EVENT_NAMES[:VIEWED_WORKSPACES_AND_PROJECTS_FEATURE]))
               .or(Ahoy::Event.where(name: AHOY_EVENT_NAMES[:VIEWED_PROGRESS_VISUALISATION_FEATURE]))
               .or(Ahoy::Event.where(name: AHOY_EVENT_NAMES[:VIEWED_POMODORO_TIMER_FEATURE]))
               .or(Ahoy::Event.where(name: AHOY_EVENT_NAMES[:VIEWED_PROGRESS_REWARDED_FEATURE]))
               .or(Ahoy::Event.where(name: AHOY_EVENT_NAMES[:VIEWED_LEADERBOARDS_FEATURE]))
               .or(Ahoy::Event.where(name: AHOY_EVENT_NAMES[:VIEWED_VIRTUAL_PLANT_FEATURE]))
               .group(:name)
               .count
  end

  def self.views_of_each_pricing_option
    Ahoy::Event.where(name: AHOY_EVENT_NAMES[:VIEWED_FREE_PLAN_PRICING_OPTION])
               .or(Ahoy::Event.where(name: AHOY_EVENT_NAMES[:VIEWED_MONTHLY_PLAN_PRICING_OPTION]))
               .or(Ahoy::Event.where(name: AHOY_EVENT_NAMES[:VIEWED_ANNUAL_PLAN_PRICING_OPTION]))
               .group(:name)
               .count
  end

  def self.feature_shares
    Ahoy::Event.where('name LIKE ?', "#{AHOY_EVENT_NAMES[:SHARED_FEATURE_PREFIX]}%").group(:name).count
  end

  def self.landing_page_metrics(visit_group_by_time, registration_group_by_time)
    landing_page_metrics = {}

    bounce_rate = if calculate_bounce_rate.nil?
                    'None'
                  else
                    calculate_bounce_rate
                  end

    landing_page_metrics[:bounce_rate] =
      { title: 'Bounce Rate', label: 'Bounced %', value: { 'Bounce Rate' => bounce_rate }.to_json, continuous: false,
        time_unit: nil }

    landing_page_metrics[:traffic_media] =
      { title: 'Traffic Media', label: 'Traffic %', values: calculate_traffic_media.to_json, continuous: false,
        time_unit: nil }

    landing_page_metrics[:traffic_sources] =
      { title: 'Traffic Sources', label: 'Traffic %', values: calculate_traffic_sources.to_json, continuous: false,
        time_unit: nil }

    landing_page_metrics[:visit_times] =
      { title: "Visit Times By #{visit_group_by_time.to_s.capitalize}", label: 'Visits',
        values: landing_page_visits_over_time(nil, visit_group_by_time).to_json, continuous: true,
        time_unit: visit_group_by_time.to_s }

    landing_page_metrics[:visit_locations] =
      { title: 'Visit Locations', label: 'Visits',
        values: event_locations(AHOY_EVENT_NAMES[:VISITED_LANDING_PAGE]).to_json, continuous: false, time_unit: nil }

    landing_page_metrics[:registration_times] =
      { title: "Registration Times By #{registration_group_by_time.to_s.capitalize}", label: 'Registrations',
        values: registrations_over_time(nil, registration_group_by_time).to_json, continuous: true,
        time_unit: registration_group_by_time.to_s }

    landing_page_metrics[:registration_locations] =
      { title: 'Registration Locations', label: 'Registrations',
        values: event_locations(AHOY_EVENT_NAMES[:REGISTERED_INTEREST]).to_json, continuous: false, time_unit: nil }

    landing_page_metrics[:pricing_views] =
      { title: 'Pricing Views', label: 'Views', values: views_of_each_pricing_option.to_json, continuous: false,
        time_unit: nil }

    landing_page_metrics[:feature_views] =
      { title: 'Feature Views', label: 'Views', values: views_of_each_feature.to_json, continuous: false,
        time_unit: nil }

    landing_page_metrics[:shared_features] =
      { title: 'Feature Shares', label: 'Shares', values: feature_shares.to_json, continuous: false,
        time_unit: nil }

    landing_page_metrics
  end

  def self.get_traffic_proportions(utm_traffic_parameter)
    traffic_parameter_counts = Ahoy::Visit.where.not(utm_traffic_parameter => nil).group(utm_traffic_parameter).count

    total_visits_from_traffic_parameter = traffic_parameter_counts.values.sum

    traffic_parameter_counts_desc = traffic_parameter_counts.sort_by { |_, count| -count }.to_h

    traffic_parameter_counts_desc.transform_values do |v|
      "#{((v.to_f / total_visits_from_traffic_parameter) * 100).round(2)}%"
    end
  end

  def self.get_location_counts_from_events(events)
    event_locations = Array.new(events.count) { {} }

    events.each_with_index do |event, index|
      event_locations[index][:country] = event.properties['country']
      event_locations[index][:city] = event.properties['city']
    end

    event_locations.tally
  end

  private_class_method :get_traffic_proportions, :get_location_counts_from_events
end
