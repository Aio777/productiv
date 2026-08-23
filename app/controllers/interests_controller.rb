# frozen_string_literal: true

class InterestsController < ApplicationController
  include RequestExtendable

  def create
    @interest = Interest.new(interest_params)

    if @interest.save
      add_ip_to_request_path_parameters(request.path_parameters, request.remote_ip)
      add_location_to_request_path_parameters(request.path_parameters)
      request.path_parameters['registration_email'] = interest_params[:email]

      Metrics::MetricTrackerService.new(ahoy).track_registering_interest(request)

      flash[:notice] = "Thanks! You're on the early access list."
    else
      flash[:alert] = @interest.errors.full_messages.to_sentence
    end

    redirect_to root_path
  end

  private

  def interest_params
    params.require(:interest).permit(:name, :email)
  end
end
