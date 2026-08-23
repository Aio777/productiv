# frozen_string_literal: true

class Subscriber::BaseController < ApplicationController
  layout 'subscriber'

  before_action :authenticate_user!
  before_action :authorize_subscriber!
  before_action :set_user_items

  private

  def authorize_subscriber!
    authorize! :access, :subscriber
  end

  def set_user_items
    @user_items = Poro::Subscriber.new(current_user).set_user_items
  end
end
