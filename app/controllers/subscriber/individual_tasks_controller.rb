# frozen_string_literal: true

class Subscriber::IndividualTasksController < Subscriber::BaseController
  before_action :redirect_non_frame_requests!, only: %i[new show]
  include RequestExtendable

  def show
    @task = current_user.individual_project.individual_tasks.find(params[:id])

    return if @task

    redirect_to subscriber_project_path, status: :not_found, alert: 'Task not found.'
  end

  def new
    @task = current_user.individual_project.individual_tasks.new
  end

  def create
    @task = current_user.individual_project.individual_tasks.new(task_params)
    @task.reminder_date = nil if params[:reminder_enabled].blank?
    @task.points = PointsService.calc_individual_task_points(task_params) || 0

    if @task.save
      Metrics::MetricTrackerService.new(ahoy).track_individual_task_created(current_user.id, @task.id, request)

      unless @task.reminder_date.nil?
        Metrics::MetricTrackerService.new(ahoy).track_individual_task_reminder_set(current_user.id, @task.id, request)
      end

      NotificationsService.update_individual_task_notifications(@task)

      redirect_to subscriber_project_path(task_id: @task.id), notice: 'Task created.'
    else
      redirect_to subscriber_project_path, status: :unprocessable_content, alert: 'Failed to create task.'
    end
  end

  def update
    @task = current_user.individual_project.individual_tasks.find(params[:id])

    unless @task
      redirect_to subscriber_project_path, status: :not_found, alert: 'Task not found.'
      return
    end

    update_params = task_params
    update_params[:reminder_date] = nil if params[:reminder_enabled].blank?
    update_params[:points] = PointsService.calc_individual_task_points(update_params) || @task.points

    old_task_reminder_date = @task.reminder_date

    if @task.update(update_params)
      if @task.reminder_date != old_task_reminder_date
        Metrics::MetricTrackerService.new(ahoy)
                                     .track_individual_task_reminder_updated(current_user.id, @task.id, request)
      end

      NotificationsService.update_individual_task_notifications(@task)
      redirect_to subscriber_project_path(task_id: @task.id), notice: 'Task updated.'
    else
      redirect_to subscriber_project_path, status: :unprocessable_content, alert: 'Failed to update task.'
    end
  end

  def complete
    @task = current_user.individual_project.individual_tasks.find(params[:id])
    @user = current_user

    if @task.update(status_complete: true) && @user.update(points: @user.points + @task.points)
      Metrics::MetricTrackerService.new(ahoy).track_individual_task_completed(current_user.id, @task.id, request)

      add_task_points_to_request_path_parameters(request.path_parameters, @task.points)
      NotificationsService.destroy_individual_task_notifications(@task)

      Metrics::MetricTrackerService.new(ahoy)
                                   .track_individual_task_points_earned(@user.id, @task.points, @task.id, request)

      redirect_to subscriber_project_path, notice: 'Task marked as complete.'
    else
      redirect_to subscriber_project_path, status: :unprocessable_content, alert: 'Failed to mark task as complete.'
    end
  end

  def destroy
    @task = current_user.individual_project.individual_tasks.find(params[:id])
    @task.destroy
    redirect_to subscriber_project_path, notice: 'Task deleted.'
  end

  private

  def redirect_non_frame_requests!
    redirect_to subscriber_project_path unless turbo_frame_request?
  end

  def task_params
    params.require(:individual_task).permit(
      :name,
      :description,
      :due_date,
      :reminder_date,
      :difficulty,
      :status_complete
    )
  end
end
