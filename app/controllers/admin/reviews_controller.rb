# frozen_string_literal: true

class Admin::ReviewsController < Admin::BaseController
  before_action :set_admin_review, only: %i[show destroy]
  before_action :set_reviews_pagination, only: %i[index]

  def index
    @review_index_one = Review.find_by(review_index: 1)
    @review_index_two = Review.find_by(review_index: 2)
    @review_index_three = Review.find_by(review_index: 3)

    @rev1_others = Review.where.not(id: @review_index_one&.id)
    @rev2_others = Review.where.not(id: @review_index_two&.id)
    @rev3_others = Review.where.not(id: @review_index_three&.id)
  end

  def show; end

  def update_review
    index = params[:index].to_i
    review_id = params[:review_id]

    Review.where(review_index: index).update_all(review_index: nil)

    Review.find(review_id).update!(review_index: index) if review_id.present?

    redirect_to admin_reviews_path(page: @page, sort: @sort), notice: 'Displayed review updated successfully.'
  end

  def destroy
    @admin_review.destroy!
    reload_after_update('Review was successfully destroyed.')
  end

  private

  def set_admin_review
    @admin_review = Review.find(params[:id])
  end

  def set_reviews_pagination
    reviews_per_page = 10
    @page = (params[:page] || 1).to_i
    sort = params[:sort].presence || 'rating'

    sort_by = {
      'interest' => Arel.sql('(positive_interest_count - negative_interest_count) DESC'),
      'rating' => { rating: :desc }
    }

    all_admin_reviews = Review.order(sort_by[sort])
    @sort = sort
    @total_pages = (Review.count / reviews_per_page.to_f).ceil
    @admin_reviews = all_admin_reviews.limit(reviews_per_page).offset((@page - 1) * reviews_per_page)
  end

  def admin_review_params
    params.require(:review).permit(:rating, :body)
  end

  def render_reviews_table
    render turbo_stream: [
      turbo_stream.remove('modal'),
      turbo_stream.replace(
        'reviews_table',
        partial: 'admin/reviews/reviews_table',
        locals: {
          page: @page,
          sort: @sort
        }
      )
    ]
  end

  def redirect_after_update(notice)
    redirect_to admin_reviews_path(page: @page, sort: @sort),
                notice: notice,
                status: :see_other
  end

  def reload_after_update(notice)
    set_reviews_pagination
    respond_to do |format|
      format.html { redirect_after_update(notice) }
      format.turbo_stream { render_reviews_table }
    end
  end
end
