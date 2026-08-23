# frozen_string_literal: true

class InvitationMailer < ActionMailer::Base
  default from: 'Productiv <no-reply@sheffield.ac.uk>'

  def new_shared_invite_email(email, team_project)
    @url = root_url
    @email = email
    @team_project = team_project
    @lead = team_project.team_lead

    mail(
      to: @email,
      subject: "Productiv! Invitiation to #{team_project.name}"
    )
  end
end
