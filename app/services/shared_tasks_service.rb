# frozen_string_literal: true

class SharedTasksService
  def self.find_team_project(params)
    new(params: params).find_team_project
  end

  def self.task_params(params)
    new(params: params).task_params
  end

  def self.complete_and_assign_user_points(task, task_points)
    new(task: task, task_points: task_points).complete_and_assign_user_points
  end

  def self.assign_members(task, params, current_user)
    team_project = task.team_project

    if team_project.team_lead != current_user
      raise ActionController::RoutingError, 'Only the team lead can assign members to tasks.'
    end

    member_ids = params[:member_ids] || []
    members_to_assign = team_project.team_project_members.where(id: member_ids)

    task.assigned_members = members_to_assign
    task.points = PointsService.calc_points_for_assignment(task) || task.points

    return true if task.save

    false
  end

  def initialize(params: nil, task: nil, task_points: nil)
    @params = params
    @task = task
    @task_points = task_points
  end

  def find_team_project
    TeamProject.find(team_project_id_from_params)
  end

  def task_params
    key =
      if @params[:team_project_task].present?
        :team_project_task
      elsif @params[:shared_task].present?
        :shared_task
      else
        raise ActionController::ParameterMissing, 'team_project_task or shared_task'
      end

    @params.require(key).permit(
      :points,
      :team_project_id,
      :name,
      :description,
      :due_date,
      :reminder_date,
      :difficulty,
      :status_complete
    )
  end

  def complete_and_assign_user_points
    assigned_members = @task.assigned_members.includes(:user).to_a
    return false if assigned_members.empty?

    points_per_user = (@task_points.to_f / assigned_members.size).ceil

    ActiveRecord::Base.transaction do
      @task.update!(status_complete: true)

      assigned_members.each do |member|
        user = member.user

        member.update!(points: member.points + points_per_user)
        user.update!(points: user.points + points_per_user)
      end
    end

    true
  rescue ActiveRecord::ActiveRecordError
    false
  end

  private

  def team_project_id_from_params
    @params[:team_project_id] || TeamProjectTask.find(@params[:id]).team_project_id
  end
end
