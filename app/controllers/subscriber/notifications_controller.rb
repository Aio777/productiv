# frozen_string_literal: true

class Subscriber::NotificationsController < Subscriber::BaseController
  def index
    @notifications = current_user.notifications
    @active_tab = params[:tab] || 'reminders'

    @reminders = Notification.none
    @team_reminders = Notification.none
    @invitations = Notification.none

    case @active_tab
    when 'reminders'
      @reminders = current_user.notifications
                               .where.not(individual_task_id: nil)
                               .includes(:individual_task)
                               .order(read: :asc, created_at: :desc)

    when 'team_reminders'
      @team_reminders = current_user.notifications
                                    .where.not(team_project_task_id: nil)
                                    .includes(team_project_task: :team_project)
                                    .order(read: :asc, created_at: :desc)

    when 'invites'
      @invitations = current_user.notifications
                                 .where.not(shared_invite_id: nil)
                                 .order(created_at: :desc)
    end

    @all_read = Notification.all_read_for?(current_user)
  end

  def mark
    @notification = current_user.notifications.find(params[:id])
    @notification.update!(read: !@notification.read)

    @active_tab = params[:tab] || 'reminders'
    @all_read = Notification.all_read_for?(current_user)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to subscriber_notifications_path(tab: @active_tab) }
    end
  end

  def accept_invitation
    notification = current_user.notifications.find(params[:id])
    shared_invite = notification.shared_invite

    unless shared_invite
      redirect_to subscriber_notifications_path, status: :not_found, alert: 'Invitation not found.'
      return
    end

    team_project = shared_invite.team_project

    if !team_project.users.include?(current_user)
      Metrics::MetricTrackerService.new(ahoy)
                                   .track_accepting_join_project_notification(current_user.id, team_project.id, request)

      TeamProjectMember.create!(team_project: team_project, user: current_user, role: 'team_member',
                                joined_at: Time.current, leaderboard_visibility: true)
      notification.update(read: true)
      notification.shared_invite.destroy
    else
      redirect_to subscriber_shared_project_path(team_project), notice: 'You are already a member of this project.'
      return
    end

    redirect_to subscriber_shared_project_path(team_project),
                notice: "You've joined the project \"#{team_project.name}\"."
  end

  def decline_invitation
    notification = current_user.notifications.find(params[:id])
    shared_invite = notification.shared_invite

    unless shared_invite
      notification.destroy
      redirect_to subscriber_notifications_path, status: :not_found, alert: 'Invitation not found.'
      return
    end

    team_project = shared_invite.team_project

    Metrics::MetricTrackerService.new(ahoy)
                                 .track_rejecting_join_project_notification(current_user.id, team_project.id, request)

    notification.update(read: true)
    notification.shared_invite.destroy

    redirect_to subscriber_shared_projects_path,
                notice: "You've declined the invitation to join \"#{team_project.name}\"."
  end
end
