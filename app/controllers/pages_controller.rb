# frozen_string_literal: true

class PagesController < ApplicationController
  include RequestExtendable

  def home
    add_ip_to_request_path_parameters(request.path_parameters, request.remote_ip)
    add_location_to_request_path_parameters(request.path_parameters)
    Metrics::MetricTrackerService.new(ahoy).track_visiting_landing_page(request)

    @posts = posts_with_admin_answers
    @posts_count = Post.count
    @reviews = Review.order(:review_index).limit(3)
    @new_post = Post.new
    @reply = Post.new
  end

  private

  def posts_with_admin_answers
    Post
      .joins(:replies)
      .where(replies: { answer_by_admin: true }, hidden: false)
      .order(created_at: :desc)
      .distinct
  end
  # rubocop:enable Metrics/MethodLength
end
