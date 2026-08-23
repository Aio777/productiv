# frozen_string_literal: true

# Class containing the domain logic for a Reporter User.
class Poro::Reporter < Poro::User
  def dashboard_data
    if @user.layout.nil? || @user.layout.negative? || @user.layout > 15
      raise InvalidLayoutValueError.new(@user.id, @user.layout)
    end

    display_values = DASHBOARD_LAYOUT_GRAPH_DISPLAY[@user.layout]
    graph_data = []

    landing_page_visits_over_time(display_values, graph_data)
    landing_page_registrations_over_time(display_values, graph_data)
    landing_page_traffic_sources(display_values, graph_data)
    active_users_over_time(display_values, graph_data)

    graph_data
  end

  private

  def landing_page_visits_over_time(display_values, graph_data)
    return unless display_values[0] == true

    landing_page_visit_time_events = Metrics::LandingPageMetrics.landing_page_visits_over_time(nil, :week)
    graph_data.push({
                      title: 'Landing Page Visits By Week',
                      label: 'Visits',
                      values: landing_page_visit_time_events.to_json,
                      continuous: true,
                      time_unit: 'week'
                    })
  end

  def landing_page_registrations_over_time(display_values, graph_data)
    return unless display_values[1] == true

    landing_page_registration_time_events = Metrics::LandingPageMetrics.registrations_over_time(nil, :week)
    graph_data.push({
                      title: 'Landing Page Registrations By Week',
                      label: 'Registrations',
                      values: landing_page_registration_time_events.to_json,
                      continuous: true,
                      time_unit: 'week'
                    })
  end

  def landing_page_traffic_sources(display_values, graph_data)
    return unless display_values[2] == true

    landing_page_traffic_sources = Metrics::LandingPageMetrics.calculate_traffic_sources
    graph_data.push({
                      title: 'Landing Page Traffic Sources',
                      label: 'Traffic %',
                      values: landing_page_traffic_sources.to_json,
                      continuous: false,
                      time_unit: nil
                    })
  end

  def active_users_over_time(display_values, graph_data)
    return unless display_values[3] == true

    active_users_over_time = Metrics::UserGrowthMetrics.active_users(:week)

    graph_data.push({
                      title: 'Active Users By Week',
                      label: 'Active Users',
                      values: active_users_over_time.to_json,
                      continuous: true,
                      time_unit: 'week'
                    })
  end
end
