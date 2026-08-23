# frozen_string_literal: true

class SharedInviteService
  def self.create_shared_invites_on_create(lead, team_project, team_project_params)
    Array(team_project_params[:invite_emails]).reject(&:blank?).each do |email|
      user_exists = team_project.team_project_members.joins(:user).exists?(users: { email: email })

      next unless !SharedInvite.find_by(team_project: team_project, email: email) && !user_exists

      shared_invite = SharedInvite.create!(
        team_project: team_project,
        email: email
      )
      user = User.find_by(email: email)
      InvitationMailer.new_shared_invite_email(email, team_project).deliver_later
      next unless user.present?

      Notification.find_or_create_by!(
        user: user,
        shared_invite: shared_invite,
        message:
            "You've been invited to join the project \"#{team_project.name}\" by #{lead.first_name} #{lead.last_name}."
      )
    end
  end

  def self.create_shared_invites_on_update(lead, team_project, team_project_params)
    Array(team_project_params[:invite_emails]).reject(&:blank?).each do |email|
      user_exists = team_project.team_project_members.joins(:user).exists?(users: { email: email })

      next unless !SharedInvite.find_by(team_project: team_project, email: email) && !user_exists

      shared_invite = SharedInvite.create!(
        team_project: team_project,
        email: email
      )
      user = User.find_by(email: email)
      InvitationMailer.new_shared_invite_email(email, team_project).deliver_later

      next unless user.present?

      Notification.find_or_create_by!(
        user: user,
        shared_invite: shared_invite,
        message:
            "You've been invited to join the project \"#{team_project.name}\" by #{lead.first_name} #{lead.last_name}."
      )
    end
  end
end
