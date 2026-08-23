# frozen_string_literal: true

class Reporter::DashboardController < Reporter::BaseController
  def index
    @display_values = Poro::Reporter::DASHBOARD_LAYOUT_GRAPH_DISPLAY[current_user.layout]
    @dashboard_data = Poro::Reporter.new(current_user).dashboard_data
  end

  def update
    if current_user.update(layout: calculate_layout)
      redirect_to reporter_root_path, notice: "User's KPIs were successfully updated.", status: :see_other
    else
      redirect_to reporter_root_path, notice: "User's KPIs failed to update.", status: :unprocessable_content
    end
  end

  private

  def user_params
    params.expect(user: %i[
                    landing_page_visits_time_toggled
                    landing_page_registrations_time_toggled
                    landing_page_traffic_sources_toggled
                    active_users_over_time_toggled
                  ])
  end

  def calculate_layout
    layout = 0
    layout += 1 if user_params[:landing_page_visits_time_toggled] == '1'
    layout += 2 if user_params[:landing_page_registrations_time_toggled] == '1'
    layout += 4 if user_params[:landing_page_traffic_sources_toggled] == '1'
    layout += 8 if user_params[:active_users_over_time_toggled] == '1'
    layout
  end
end
