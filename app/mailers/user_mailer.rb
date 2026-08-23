# frozen_string_literal: true

class UserMailer < ActionMailer::Base
  default from: 'Productiv <no-reply@sheffield.ac.uk>'

  def new_user_email(user, temp_password)
    @user = user
    @temp_password = temp_password
    @url = new_user_session_url

    mail(
      to: @user.email,
      subject: 'Your account has been created - temporary password inside'
    )
  end
end
