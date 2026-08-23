# frozen_string_literal: true

class Admin::BaseController < ApplicationController
  layout 'admin'

  before_action :authenticate_user!
  before_action :authorize_admin!

  private

  def authorize_admin!
    authorize! :access, :admin
  end
end
