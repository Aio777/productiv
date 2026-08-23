# frozen_string_literal: true

class Admin::InterestsController < Admin::BaseController
  before_action :set_admin_interest, only: %i[show destroy]
  before_action :set_interests_pagination, only: %i[index]

  def index; end

  def show
    @registration_timeline = RegistrationJourneyService.register_interest_events_timeline(@admin_interest.email)
  end

  def destroy
    @admin_interest.destroy!
    reload_after_update('Interest was successfully destroyed.')
  end

  private

  def set_admin_interest
    @admin_interest = Interest.find(params.expect(:id))
  end

  def set_interests_pagination
    interests_per_page = 10
    @page = (params[:page] || 1).to_i
    all_admin_interests = Interest.order(created_at: :desc)
    @total_pages = (Interest.count / interests_per_page.to_f).ceil
    @admin_interests = all_admin_interests.limit(interests_per_page).offset((@page - 1) * interests_per_page)
  end

  def render_interests_table
    render turbo_stream: [
      turbo_stream.remove('modal'),
      turbo_stream.replace(
        'interests_table',
        partial: 'admin/interests/interests_table',
        locals: {
          page: @page,
          total_pages: @total_pages
        }
      )
    ]
  end

  def redirect_after_update(notice)
    redirect_to admin_interests_path(page: @page),
                notice: notice,
                status: :see_other
  end

  def reload_after_update(notice)
    set_interests_pagination
    respond_to do |format|
      format.html { redirect_after_update(notice) }
      format.turbo_stream { render_interests_table }
    end
  end
end
