# frozen_string_literal: true

class Subscriber::ProjectsController < Subscriber::BaseController
  def show
    @project = current_user.individual_project

    @tasks = @project.individual_tasks.where(status_complete: false).order(due_date: :asc)

    if params[:task_id]
      @task = @project.individual_tasks.find_by(id: params[:task_id])
    elsif @tasks.any?
      @task = @tasks.first
    end

    redirect_to subscriber_root_path, status: :not_found, alert: 'Project not found' unless @project
  end
end
