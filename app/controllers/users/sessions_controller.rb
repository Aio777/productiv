# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  layout 'login'

  protected

  def after_sign_in_path_for(user)
    if user.admin?
      admin_root_path
    elsif user.reporter?
      reporter_root_path
    elsif user.subscriber?
      Metrics::MetricTrackerService.new(ahoy).track_user_signed_in(user.id, request)
      NotificationsService.initialise_individual_task_notifications(user)
      NotificationsService.initialise_shared_task_notifications(user)
      subscriber_root_path
    else
      root_path
    end
  end
end
