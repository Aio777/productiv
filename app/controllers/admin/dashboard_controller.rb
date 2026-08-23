# frozen_string_literal: true

class Admin::DashboardController < Admin::BaseController
  before_action :authorize_admin!

  def index
    @users_count = User.count
    @posts_count = Post.count
    @reviews_count = Review.count

    @recent_posts   = Post.where(parent_id: nil).includes(:replies).order(created_at: :desc).limit(5)
    @recent_reviews = Review.order(created_at: :desc).limit(5)
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
end
