# frozen_string_literal: true

class Subscriber::SharedProjectsController < Subscriber::BaseController
  before_action :set_team_project,
                only: %i[show edit team_member_edit leaderboard update update_team_member remove_team_member destroy]

  def index
    @team_projects = current_user.team_projects.includes(:team_project_tasks)
  end

  def show
    @tasks = @team_project.team_project_tasks.where(status_complete: false).order(due_date: :asc)

    if params[:task_id]
      @task = @team_project.team_project_tasks.find_by(id: params[:task_id])
    elsif @tasks.any?
      @task = @tasks.first
    end

    @project_members = if @task
                         @team_project.team_project_members.includes(:user)
                       else
                         @team_project.team_project_members
                       end
    @current_member = @team_project.team_project_members.find_by(user: current_user)

    @radar_categories = @team_project.radar_categories
    @radar_ratings = @team_project
                     .radar_ratings.where(team_project_member: @current_member)
                     .index_by(&:radar_category_id)
  end

  def new
    @team_project = TeamProject.new
  end

  def edit
    lead_only_action

    @project_members = @team_project
                       .team_project_members
                       .includes(:user)
                       .where.not(user: current_user)
  end

  def team_member_edit
    member_only_action

    @project_members = @team_project.team_project_members.includes(:user)
    @current_member = @project_members.find { |member| member.user_id == current_user.id }
  end

  def update_team_member
    member_only_action

    @current_member = @team_project.team_project_members.find_by(user: current_user)

    TeamProjectService.update_member_leaderboard_visibility(@current_member, params)
    TeamProjectService.update_member_radar_ratings(@current_member, radar_ratings_params)

    redirect_to subscriber_shared_project_settings_path(@team_project), notice: 'Successfully updated your preferences'
  end

  def remove_team_member
    member_only_action

    @current_member = @team_project.team_project_members.find_by(user: current_user)

    if @current_member.destroy
      redirect_to subscriber_shared_projects_path, notice: "Successfully left the team project: #{@team_project.name}"
    else
      redirect_to subscriber_shared_project_settings_path(@team_project), alert: 'Failed to leave the team project.'
    end
  end

  def leaderboard
    redirect_to subscriber_shared_project_path(@team_project) unless @team_project.leaderboard_visible?

    @project_members = @team_project.team_project_members.includes(:user).order(points: :desc)
  end

  def create
    @team_project = TeamProject.new(team_project_base_params)

    begin
      TeamProjectService.set_radar_categories(team_project_params, @team_project)
    rescue ArgumentError => e
      redirect_to new_subscriber_shared_project_path, alert: "Skills Radar: #{e.message}"
      return
    end

    if TeamProjectService.create_new_team_project(@team_project, current_user, team_project_params)
      redirect_to subscriber_shared_projects_path, notice: 'Project was successfully created.'
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    lead_only_action

    begin
      TeamProjectService.set_radar_categories(team_project_params, @team_project)
    rescue ArgumentError => e
      redirect_to edit_subscriber_shared_project_path(@team_project), alert: "Skills Radar: #{e.message}"
      return
    end

    unless @team_project.update(team_project_update_params)
      redirect_to edit_subscriber_shared_project_path(@team_project), status: :unprocessable_entity
    end

    TeamProjectService.configure_team_members(@team_project, team_project_params)

    redirect_to edit_subscriber_shared_project_path(@team_project), notice: 'Project was successfully updated.'
  end

  def destroy
    lead_only_action

    @team_project.destroy
    redirect_to subscriber_shared_projects_path, notice: 'Project was successfully deleted.'
  end

  private

  def team_project_params
    raw = params.require(:team_project).permit(
      :name,
      :description,
      :image_path,
      :leaderboard_visible,
      radar_categories: [],
      invite_emails: [],
      remove_member_ids: []
    )

    TeamProjectService.process_params(raw)
  end

  def lead_only_action
    return unless @team_project.team_lead != current_user

    redirect_to subscriber_shared_projects_path, alert: 'Only the team lead can do this action.'
  end

  def member_only_action
    return unless @team_project.team_lead == current_user

    redirect_to subscriber_shared_projects_path, alert: 'Only team members can access this page.'
  end

  def set_team_project
    @team_project = current_user.team_projects.find_by(id: params[:id])
    return if @team_project

    redirect_to subscriber_shared_projects_path, alert: 'Action Forbidden'
  end

  def team_project_base_params
    team_project_params.slice(:name, :description, :image_path)
  end

  def team_project_update_params
    hide = params[:hide_leaderboard] == '1'

    team_project_base_params.merge(
      leaderboard_visible: !hide
    )
  end

  def radar_ratings_params
    params.require(:team_project).permit(radar_ratings: {})
  end
end
