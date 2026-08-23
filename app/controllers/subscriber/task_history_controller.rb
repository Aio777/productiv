# frozen_string_literal: true

class Subscriber::TaskHistoryController < Subscriber::BaseController
  def index
    @active_tab = params[:tab].presence || 'individual_tasks'

    @individual_tasks = current_user.individual_project.individual_tasks.where(status_complete: true)
                                    .order(updated_at: :desc)

    @shared_tasks = TeamProjectTask
                    .joins(team_task_assignments: :team_project_member)
                    .where(status_complete: true)
                    .where(team_project_members: { user_id: current_user.id })
                    .distinct
                    .order(updated_at: :desc)
  end
end
