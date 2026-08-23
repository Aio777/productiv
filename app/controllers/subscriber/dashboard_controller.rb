# frozen_string_literal: true

class Subscriber::DashboardController < Subscriber::BaseController
  decorates_assigned :plant

  def index
    @plant = current_user.plant

    @display_values = Poro::Subscriber::DASHBOARD_LAYOUT_GRAPH_DISPLAY[current_user.layout]
    @dashboard_data = Poro::Subscriber.new(current_user).dashboard_data
  end

  def update
    if current_user.update(layout: calculate_layout)
      redirect_to subscriber_root_path, notice: "User's KPIs were successfully updated.", status: :see_other
    else
      redirect_to subscriber_root_path, notice: "User's KPIs failed to update.", status: :unprocessable_content
    end
  end

  private

  def user_params
    params.expect(user: %i[
                    tasks_completed_toggled
                    pomodoro_sessions_toggled
                    tasks_created_toggled
                    points_earned_toggled
                  ])
  end

  def calculate_layout
    layout = 0
    layout += 1 if user_params[:tasks_completed_toggled] == '1'
    layout += 2 if user_params[:pomodoro_sessions_toggled] == '1'
    layout += 4 if user_params[:tasks_created_toggled] == '1'
    layout += 8 if user_params[:points_earned_toggled] == '1'
    layout
  end
end
