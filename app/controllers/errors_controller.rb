# frozen_string_literal: true

class ErrorsController < ActionController::Base
  before_action :check_db_status

  def bad_request
    render status: :bad_request
  end

  def not_found
    render status: :not_found
  end

  def not_acceptable
    render status: :not_acceptable
  end

  def unprocessable
    render status: :unprocessable_content
  end

  def internal_server_error
    render status: :internal_server_error
  end

  def bad_gateway
    render status: :bad_gateway
  end

  def service_unavailable
    render status: :service_unavailable
  end

  private

  def check_db_status
    @db_available = begin
      ActiveRecord::Base.connection_pool.with_connection(&:active?)
    rescue StandardError
      false
    end
  end
end
