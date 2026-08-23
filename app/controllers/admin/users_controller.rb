# frozen_string_literal: true

class Admin::UsersController < Admin::BaseController
  before_action :skip_devise_params_sanitization
  before_action :set_admin_user, only: %i[show edit update destroy]
  before_action :set_users_pagination, only: %i[index update]

  def index; end

  def show; end

  def new
    @user = User.new
  end

  def edit; end

  def create
    if %w[admin reporter].include?(invite_params[:role])
      @user = User.invite!(invite_params.merge(invited_by_id: current_user.id, was_subscriber: false, layout: 15))

      if @user.errors.empty?
        redirect_to admin_users_path, notice: "Invitation sent to #{@user.email}."
      else
        Rails.logger.error(@user.errors.full_messages)
        render :new, status: :unprocessable_content
      end
    else
      @user = User.new
      @user.errors.add(:role, 'is not allowed for new users')

      Rails.logger.error(@user.errors.full_messages)
      render :new, status: :unprocessable_content
    end
  end

  def update
    if subscriber_role_upgrade?(@user)
      UserService.upgrade_user_role(@user, admin_user_params)
      reload_after_update('User was successfully updated.')
      return
    end

    if @user.update(admin_user_params)
      reload_after_update('User was successfully updated.')
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    led_projects = TeamProject.joins(:team_project_members).where(team_project_members: { user_id: @user.id,
                                                                                          role: 'team_lead' }).to_a
    SharedInvite.where(email: @user.email).destroy_all
    led_projects.each(&:destroy)
    @user.destroy!
    reload_after_update('User was successfully destroyed.')
  end

  private

  def set_admin_user
    @user = User.find(params[:id])
  end

  def set_users_pagination
    users_per_page = 10
    @role = params[:role].presence || 'subscriber'
    @page = (params[:page] || 1).to_i
    sort = params[:sort].presence || 'last_name'

    sort_by = {
      'last_name' => { last_name: :asc },
      'first_name' => { first_name: :asc }
    }

    users_relevant = User.where(role: @role).where.not(id: current_user.id).order(sort_by[sort])
    @sort = sort
    @total_pages = (users_relevant.count / users_per_page.to_f).ceil
    @users = users_relevant.limit(users_per_page).offset((@page - 1) * users_per_page)
  end

  def admin_user_params
    # brakeman:ignore PermitAttributes - role is safe and controlled internally
    params.require(:user).permit(:first_name, :last_name, :email, :role)
  end

  def skip_devise_params_sanitization
    request.env['devise.skip_parameter_sanitization'] = true
  end

  def invite_params
    allowed = %i[first_name last_name email]

    allowed << :role if current_user.admin?

    params.require(:user).permit(allowed)
  end

  def subscriber_role_upgrade?(user)
    role_upgrade = 'admin' || 'reporter'
    was_sub = user.was_subscriber
    was_sub && admin_user_params[:role] == role_upgrade
  end

  def render_users_table
    render turbo_stream: [
      turbo_stream.remove('modal'),
      turbo_stream.replace(
        'users_table',
        partial: 'admin/users/users_table',
        locals: {
          role: @role,
          page: @page,
          sort: @sort,
          users: @users,
          total_pages: @total_pages
        }
      )
    ]
  end

  def redirect_after_update(notice)
    redirect_to admin_users_path(role: @role, page: @page, sort: @sort),
                notice: notice,
                status: :see_other
  end

  def reload_after_update(notice)
    set_users_pagination
    respond_to do |format|
      format.html { redirect_after_update(notice) }
      format.turbo_stream { render_users_table }
    end
  end
end
