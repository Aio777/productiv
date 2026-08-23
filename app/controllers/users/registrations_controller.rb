# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  layout 'login'

  protected

  def after_sign_up_path_for(user)
    Metrics::MetricTrackerService.new(ahoy).track_user_signed_in(user.id, request)
    UserService.initialise_shared_invites(user)
    subscriber_root_path
  end
end
