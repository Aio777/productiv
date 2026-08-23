# frozen_string_literal: true

# Class containing the domain logic for a Subscriber User.
class Poro::Subscriber < Poro::User
  class InsufficientPointsForWateringPlantError < StandardError
    attr_reader :user_id, :user_points

    def initialize(user_id, user_points)
      @user_id = user_id
      @user_points = user_points

      super("User #{@user_id} only has #{@user_points} point(s). #{WATER_PLANT_POINTS} point(s) are required to water
      their plant.")
    end
  end

  class InsufficientPointsForBuyingItem < StandardError
    attr_reader :user_id, :user_points, :item_name, :item_price

    def initialize(user_id, user_points, item_name, item_price)
      @user_id = user_id
      @user_points = user_points
      @item_name = item_name
      @item_price = item_price

      super("User #{@user_id} failed to buy '#{@item_name}' with a price of #{@item_price} point(s). The user only has
      #{@user_points} points.")
    end
  end

  WATER_PLANT_POINTS = 10

  def set_user_items
    plant_items = Item.where(category: 'plant')
    user_plant_items = Item.joins(:user_items).where(user_items: { user: @user, item: plant_items }).distinct
                           .pluck(:name, :id)

    pot_items = Item.where(category: 'pot')
    user_pot_items = Item.joins(:user_items).where(user_items: { user: @user, item: pot_items }).distinct
                         .pluck(:name, :id)

    { plant_items: user_plant_items, pot_items: user_pot_items }
  end

  def can_afford_to_water_plant?
    @user.points >= WATER_PLANT_POINTS
  end

  def pay_to_water_plant
    raise InsufficientPointsForWateringPlantError.new(@user.id, @user.points) if @user.points < WATER_PLANT_POINTS

    @user.points -= WATER_PLANT_POINTS
    @user.save
  end

  def purchase_item(item)
    if @user.points < item.price
      raise InsufficientPointsForBuyingItem.new(@user.id, @user.points, item.name, item.price)
    end

    @user.points -= item.price
    @user.save
  end

  def dashboard_data
    if @user.layout.nil? || @user.layout.negative? || @user.layout > 15
      raise InvalidLayoutValueError.new(@user.id, @user.layout)
    end

    display_values = DASHBOARD_LAYOUT_GRAPH_DISPLAY[@user.layout]
    graph_data = []

    completed_tasks_over_time(display_values, graph_data)
    pomodoro_sessions_over_time(display_values, graph_data)
    created_tasks_over_time(display_values, graph_data)
    points_earned_over_time(display_values, graph_data)

    graph_data
  end

  private

  def completed_tasks_over_time(display_values, graph_data)
    return unless display_values[0] == true

    completed_tasks = IndividualTask.where(individual_project: @user.individual_project, status_complete: true)

    graph_data.push({
                      title: 'Tasks Completed (Personal Workspace)',
                      label: 'Tasks Completed',
                      values: GroupRecords.group_records_by_time(completed_tasks, :updated_at, nil, :day).to_json,
                      continuous: true,
                      time_unit: 'day'
                    })
  end

  def pomodoro_sessions_over_time(display_values, graph_data)
    return unless display_values[1] == true

    pomodoro_sessions = Ahoy::Event.where(user: @user).where('name LIKE ?', "%#{
          Metrics::FeatureEngagementMetrics::AHOY_EVENT_NAMES[:STARTED_POMODORO_TIMER_PREFIX]
        }")

    graph_data.push({
                      title: 'Pomodoro Sessions',
                      label: 'Sessions',
                      values: GroupRecords.group_records_by_time(pomodoro_sessions, :time, nil, :day).to_json,
                      continuous: true,
                      time_unit: 'day'
                    })
  end

  def created_tasks_over_time(display_values, graph_data)
    return unless display_values[2] == true

    created_tasks = IndividualTask.where(individual_project: @user.individual_project)

    graph_data.push({
                      title: 'Tasks Created (Personal Workspace)',
                      label: 'Tasks Created',
                      values: GroupRecords.group_records_by_time(created_tasks, :created_at, nil, :day).to_json,
                      continuous: true,
                      time_unit: 'day'
                    })
  end

  def points_earned_over_time(display_values, graph_data)
    return unless display_values[3] == true

    points_earned_per_day = Ahoy::Event.where(user: @user).where('name LIKE ?', "%#{
          Metrics::GamificationMetrics::AHOY_EVENT_NAMES[:EARNED_POINTS_FROM_INDIVIDUAL_TASK_PREFIX]
        }%").or(
          Ahoy::Event.where(user: @user).where('name LIKE ?', "%#{
            Metrics::GamificationMetrics::AHOY_EVENT_NAMES[:EARNED_POINTS_FROM_SHARED_TASK_PREFIX]
          }%")
        ).group_by_day(:time, series: false).sum("(properties->>'task_points')::int")

    graph_data.push({
                      title: 'Points Earned',
                      label: 'Points',
                      values: points_earned_per_day.to_json,
                      continuous: true,
                      time_unit: 'day'
                    })
  end
end
