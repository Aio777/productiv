# frozen_string_literal: true

# The superclass for the User classes to inherit.
class Poro::User
  attr_reader :user

  DASHBOARD_LAYOUT_GRAPH_DISPLAY = {
    0 => [false, false, false, false],
    1 => [true, false, false, false],
    2 => [false, true, false, false],
    3 => [true, true, false, false],
    4 => [false, false, true, false],
    5 => [true, false, true, false],
    6 => [false, true, true, false],
    7 => [true, true, true, false],
    8 => [false, false, false, true],
    9 => [true, false, false, true],
    10 => [false, true, false, true],
    11 => [true, true, false, true],
    12 => [false, false, true, true],
    13 => [true, false, true, true],
    14 => [false, true, true, true],
    15 => [true, true, true, true]
  }.freeze

  class InvalidLayoutValueError < StandardError
    attr_reader :user_id, :layout

    def initialize(user_id, layout)
      @user_id = user_id
      @layout = layout
      super("User #{@user_id} has attribute 'layout' with invalid value: #{@layout}")
    end
  end

  def initialize(user)
    @user = user
  end

  def dashboard_data
    raise NoMethodError, 'This method must be implemented by User subclasses.'
  end
end
