# frozen_string_literal: true

class Subscriber::SharedTasksController < Subscriber::BaseController
  before_action :redirect_non_frame_requests!, only: %i[new show]
  include RequestExtendable

  def show
    @task = TeamProjectTask.find(params[:id])
    @team_project = @task.team_project
    @project_members = @team_project.team_project_members.includes(:user)
    @current_member = @project_members.find_by(user: current_user)
    return if @task

    redirect_to subscriber_shared_project_path(@team_project), status: :not_found, alert: 'Task not found.'
  end

  def new
    @task = TeamProjectTask.new
    @team_project = current_user.team_projects.find(params[:team_project_id])
  end

  def create
    @task = TeamProjectTask.new(SharedTasksService.task_params(params))
    @task.reminder_date = nil if params[:reminder_enabled].blank?
    @task.points = PointsService.calc_team_project_task_points(SharedTasksService.task_params(params), @task) || 0

    if @task.save
      Metrics::MetricTrackerService.new(ahoy).track_shared_task_created(current_user.id, @task.id, request)

      unless @task.reminder_date.nil?
        Metrics::MetricTrackerService.new(ahoy).track_shared_task_reminder_set(current_user.id, @task.id, request)
      end
      NotificationsService.update_shared_task_notifications(@task)

      redirect_to subscriber_shared_project_path(@task.team_project, task_id: @task.id), notice: 'Task created.'
    else
      redirect_to subscriber_shared_project_path(@task.team_project), status: :unprocessable_content,
                                                                      alert: 'Failed to create task.'
    end
  end

  def update
    @task = TeamProjectTask.find(params[:id])

    redirect_to subscriber_shared_project_path(@team_project), status: :not_found, alert: 'Task not found.' unless @task

    @team_project = @task.team_project

    if @team_project.team_lead != current_user
      redirect_to subscriber_shared_project_path(@team_project, task_id: @task.id),
                  status: :forbidden, alert: 'Only the team lead can update tasks.'
    end

    unless SharedTasksService.assign_members(@task, params, current_user)
      redirect_to subscriber_shared_project_path(@team_project, task_id: @task.id),
                  status: :unprocessable_content, alert: 'Failed to update members.'
    end

    update_params = initialise_update_params(params, @task)
    old_task_reminder_date = @task.reminder_date

    if @task.update(update_params)
      if @task.reminder_date != old_task_reminder_date
        Metrics::MetricTrackerService.new(ahoy).track_shared_task_reminder_updated(current_user.id, @task.id, request)
      end

      NotificationsService.update_shared_task_notifications(@task)

      redirect_to subscriber_shared_project_path(@team_project, task_id: @task.id), notice: 'Task updated.'
    else
      redirect_to subscriber_shared_project_path(@team_project, task_id: @task.id), status: :unprocessable_content,
                                                                                    alert: 'Failed to update task.'
    end
  end

  def complete
    @task = TeamProjectTask.find(params[:id])
    @assigned_users = @task.assigned_members
    @team_project = @task.team_project

    if SharedTasksService.complete_and_assign_user_points(@task, @task.points)
      Metrics::MetricTrackerService.new(ahoy).track_shared_task_completed(current_user.id, @task.id, request)

      NotificationsService.destroy_shared_task_notifications(@task)

      add_task_points_to_request_path_parameters(request.path_parameters, @task.points)
      Metrics::MetricTrackerService.new(ahoy)
                                   .track_shared_task_points_earned(current_user.id, @task.points, @task.id, request)

      redirect_to subscriber_shared_project_path(@team_project), notice: 'Task marked as complete.'
    else
      redirect_to subscriber_shared_project_path(@team_project), status: :unprocessable_content,
                                                                 alert: 'Failed to mark task as complete.'
    end
  end

  def destroy
    @task = TeamProjectTask.find(params[:id])
    @team_project = @task.team_project

    if @team_project.team_lead != current_user
      redirect_to subscriber_shared_project_path(@team_project), status: :forbidden,
                                                                 alert: 'You cannot delete this task.'
    end

    @task.destroy
    redirect_to subscriber_shared_project_path(@team_project), notice: 'Task deleted.'
  end

  private

  def redirect_non_frame_requests!
    @team_project = SharedTasksService.find_team_project(params)
    redirect_to subscriber_shared_project_path(@team_project) unless turbo_frame_request?
  end

  def initialise_update_params(params, task)
    update_params = SharedTasksService.task_params(params)
    update_params[:reminder_date] = nil if params[:reminder_enabled].blank?
    update_params[:points] = PointsService.calc_team_project_task_points(update_params, task) || task.points

    update_params
  end
end
