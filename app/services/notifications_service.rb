# frozen_string_literal: true

class NotificationsService
  def self.initialise_individual_task_notifications(user)
    existing_notifications = user.notifications.where.not(individual_task_id: nil)

    reminder_tasks = IndividualTask
                     .joins(:individual_project)
                     .where(reminder_date: ..Time.current, status_complete: false)
                     .where(individual_projects: { user_id: user.id })

    existing_notifications
      .where.not(individual_task_id: reminder_tasks.select(:id))
      .destroy_all

    existing_task_ids = user.notifications
                            .where.not(individual_task_id: nil)
                            .pluck(:individual_task_id)

    reminder_tasks
      .where.not(id: existing_task_ids)
      .find_each do |task|
        Notification.find_or_create_by!(
          user: user,
          individual_task_id: task.id,
          message: task.name,
          read: false
        )
      end
  end

  def self.initialise_shared_task_notifications(user)
    existing_notifications = user.notifications.where.not(team_project_task_id: nil)

    base_tasks = TeamProjectTask
                 .where(reminder_date: ..Time.current, status_complete: false)

    assigned_tasks = base_tasks
                     .joins(team_task_assignments: :team_project_member)
                     .where(team_project_members: { user_id: user.id })

    lead_project_tasks = base_tasks
                         .where(
                           team_project_id: TeamProjectMember
                             .where(user_id: user.id, role: 'team_lead')
                             .select(:team_project_id)
                         )

    reminder_tasks = assigned_tasks.or(lead_project_tasks).distinct

    existing_notifications
      .where.not(team_project_task_id: reminder_tasks.select(:id))
      .destroy_all

    existing_task_ids = user.notifications
                            .where.not(team_project_task_id: nil)
                            .pluck(:team_project_task_id)

    reminder_tasks
      .where.not(id: existing_task_ids)
      .find_each do |task|
        Notification.find_or_create_by!(
          user: user,
          team_project_task_id: task.id,
          message: task.name,
          read: false
        )
      end
  end

  def self.update_individual_task_notifications(task)
    task.notification&.destroy

    return unless task.reminder_date.present? && task.reminder_date <= Time.current

    Notification.find_or_create_by!(
      user: task.individual_project.user,
      individual_task_id: task.id,
      message: task.name,
      read: false
    )
  end

  def self.update_shared_task_notifications(task)
    task.notifications.destroy_all

    return unless task.reminder_date.present? && task.reminder_date <= Time.current

    team_lead = task.team_project.team_lead

    task.team_project_members.find_each do |member|
      Notification.find_or_create_by!(
        user: member.user,
        team_project_task_id: task.id,
        message: task.name,
        read: false
      )
    end

    Notification.find_or_create_by!(
      user: team_lead,
      team_project_task_id: task.id,
      message: task.name,
      read: false
    )
  end

  def self.destroy_shared_task_notifications(task)
    task.notifications.destroy_all
  end

  def self.destroy_individual_task_notifications(task)
    task.notification&.destroy
  end
end
