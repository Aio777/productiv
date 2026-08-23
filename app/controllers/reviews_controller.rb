# frozen_string_literal: true

class ReviewsController < ApplicationController
  before_action :set_review, only: %i[upvote downvote]

  def home
    @reviews = Review.where(review_index: [1, 2, 3], hidden: false)
                     .order(:review_index)
  end

  def upvote
    return head :forbidden if session[:review_vote]&.[](params[:id])

    @review.increment!(:positive_interest_count)
    session[:review_vote] ||= {}
    session[:review_vote][params[:id]] = 'up'

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: root_path }
    end
  end

  def downvote
    return head :forbidden if session[:review_vote]&.[](params[:id])

    @review.increment!(:negative_interest_count)
    session[:review_vote] ||= {}
    session[:review_vote][params[:id]] = 'down'

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: root_path }
    end
  end

  def new
    @review = Review.new
  end

  def create
    @review = Review.new(review_params)
    @review.hidden = true
    @review.review_index ||= Review.maximum(:review_index).to_i + 1

    if @review.save
      redirect_to root_path, notice: 'Thanks! Your review is pending approval.'
    else
      redirect_to root_path, status: :unprocessable_content
    end
  end

  private

  def review_params
    params.require(:review).permit(:name, :rating, :body)
  end

  def set_review
    @review = Review.find(params[:id])
  end
end
