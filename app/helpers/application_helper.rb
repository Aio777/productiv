# frozen_string_literal: true

module ApplicationHelper
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def dynamic_header
    # Subscriber Headings
    return "#{current_user.first_name}'s Notifications" if current_page?(subscriber_notifications_path)
    if current_page?(subscriber_root_path) || current_page?(reporter_root_path)
      return "Welcome #{current_user.first_name}"
    end
    return "#{current_user.first_name}'s Task History" if current_page?(subscriber_task_history_path)
    return "#{current_user.first_name}'s Workspace" if current_page?(subscriber_project_path)

    if params[:id].present? && shared_project_page?
      team_project = TeamProject.find_by(id: params[:id])
      return team_project.name if team_project
    end

    return "#{current_user.first_name}'s Shared Projects" if request.path.start_with?(subscriber_shared_projects_path)
    return 'Pomodoro' if current_page?(subscriber_pomodoro_path)
    return 'Item Shop' if current_page?(subscriber_items_path)

    # Reporter Headings
    return 'Landing Page Metrics' if current_page?(reporter_landing_page_metrics_path)
    return 'Feature Engagement Metrics' if current_page?(reporter_feature_engagement_metrics_path)
    return 'Gamification Metrics' if current_page?(reporter_gamification_metrics_path)

    'User Growth Metrics' if current_page?(reporter_user_growth_metrics_path)
  end
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  def dynamic_settings
    return unless params[:id].present?
    return unless shared_project_page?

    team_project = TeamProject.find_by(id: params[:id])
    return unless team_project

    path =
      if current_user == team_project.team_lead
        edit_subscriber_shared_project_path(params[:id])
      else
        subscriber_shared_project_settings_path(params[:id])
      end

    link_to path do
      content_tag(:span, 'Settings', class: 'top-link-btn-box')
    end
  end

  def dynamic_leaderboard
    return unless params[:id].present?
    return unless shared_project_page?

    team_project = TeamProject.find_by(id: params[:id])
    return unless team_project&.leaderboard_visible?

    link_to subscriber_shared_project_leaderboard_path(params[:id]) do
      content_tag(:span, 'Leaderboard', class: 'top-link-btn-box')
    end
  end

  def dynamic_progress_bar
    return unless params[:id].present?
    return unless shared_project_page?

    team_project = TeamProject.find_by(id: params[:id])
    return unless team_project

    render 'subscriber/shared_projects/progress_bar', team_project: team_project
  end

  def dynamic_project_home
    return unless params[:id].present?
    return unless shared_project_page?

    link_to subscriber_shared_project_path(params[:id]) do
      content_tag(:span, 'Tasks', class: 'top-link-btn-box')
    end
  end

  private

  def shared_project_page?
    request.path.start_with?(subscriber_shared_projects_path) ||
      request.path.start_with?(subscriber_shared_project_leaderboard_path) ||
      request.path.start_with?(subscriber_shared_project_settings_path)
  end
end
