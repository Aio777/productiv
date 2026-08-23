# frozen_string_literal: true

class UserService
  def self.initialise_shared_invites(user)
    shared_invites = SharedInvite.where(email: user.email)
    return unless shared_invites.any?

    shared_invites.each do |invite|
      team_project = invite.team_project
      lead = team_project.team_lead
      Notification.find_or_create_by!(
        user: user,
        shared_invite: invite,
        message:
            "You've been invited to join the project \"#{team_project.name}\" by #{lead.first_name} #{lead.last_name}."
      )
    end
  end

  def self.upgrade_user_role(user, admin_user_params)
    password = user.encrypted_password
    led_projects = TeamProject.joins(:team_project_members).where(team_project_members: { user_id: user.id,
                                                                                          role: 'team_lead' }).to_a
    SharedInvite.where(email: user.email).destroy_all
    led_projects.each(&:destroy)

    user.destroy!
    new_user = User.create!(
      first_name: admin_user_params[:first_name],
      last_name: admin_user_params[:last_name],
      password: 'TempPassword@1234',
      email: admin_user_params[:email],
      role: admin_user_params[:role],
      was_subscriber: false
    )
    new_user.encrypted_password = password
    new_user.save!(validate: false)

    new_user
  end
end
