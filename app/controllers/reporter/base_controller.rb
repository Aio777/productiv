# frozen_string_literal: true

class Reporter::BaseController < ApplicationController
  layout 'reporter'

  before_action :authenticate_user!
  before_action :authorize_reporter!

  def authorize_reporter!
    authorize! :access, :reporter
  end
end
