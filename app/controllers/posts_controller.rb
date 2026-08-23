# frozen_string_literal: true

class PostsController < ApplicationController
  def create
    @post = Post.new(post_params)

    if @post.save
      Metrics::MetricTrackerService.new(ahoy).track_posted_question(request)

      redirect_back fallback_location: root_path
    else
      redirect_back fallback_location: root_path, alert: 'Could not save post.', status: :unprocessable_content
    end
  end

  private

  def post_params
    params.require(:post).permit(:title, :body)
  end
end
