# frozen_string_literal: true

# Class containing the domain logic for a Plant object.
class Poro::Plant
  attr_reader :plant

  class NonSubscriberError < StandardError
    attr_reader :user_id, :user_role

    def initialize(user_id, user_role)
      @user_id = user_id
      @user_role = user_role
      super("User #{@user_id} has role: '#{@user_role}'. Only: 'subscriber' roles can have a Plant.")
    end
  end

  PLANT_STAGE_IMAGES = Subscriber::PlantHelper::PLANT_STAGE_IMAGES

  DECAY_TIME_LENGTH = 0.5.weeks
  DEATH_TIME_LENGTH = 1.week

  def initialize(plant)
    @plant = plant
  end

  def self.create_active_record_plant(user)
    raise NonSubscriberError.new(user.id, user.role) unless user.subscriber?

    base_plant_item = Item.find_or_create_by(name: 'Daisy Seed', category: 'plant',
                                             image_url: 'images/plants/daisy_seed.webp')

    base_pot_item = Item.find_or_create_by(name: 'Square Pot', category: 'pot',
                                           image_url: 'images/pots/square_default.webp')

    UserItem.create!(user: user, item: base_plant_item)
    UserItem.create!(user: user, item: base_pot_item)

    Plant.create!(user: user, plant_type: base_plant_item, plant_image: base_plant_item.image_url,
                  pot_type: base_pot_item)
  end

  def water
    plant_stage = plant_stage_index

    if plant_stage == 2
      false
    else
      if Set[0, 1].include? plant_stage
        plant_stage += 1
      elsif Set[3, 4].include? plant_stage
        plant_stage -= 1
      end

      new_plant_image = PLANT_STAGE_IMAGES[@plant.plant_type.name][plant_stage]

      @plant.plant_image = new_plant_image
      @plant.last_watered_at = DateTime.current
      @plant.save

      true
    end
  end

  def decay
    return false if can_plant_decay? == false

    new_plant_image = if @plant.last_watered_at < DEATH_TIME_LENGTH.ago
                        PLANT_STAGE_IMAGES[@plant.plant_type.name][4]
                      elsif @plant.last_watered_at < DECAY_TIME_LENGTH.ago
                        PLANT_STAGE_IMAGES[@plant.plant_type.name][3]
                      else
                        @plant.plant_image
                      end

    if new_plant_image == @plant.plant_image
      false
    else
      @plant.plant_image = new_plant_image
      @plant.save
      Metrics::MetricTrackerService.track_plant_death(@plant.user) if plant_stage_index == 4

      true
    end
  end

  def calculate_average_plant_streak
    plant_life_death_events = Ahoy::Event.where(user: @plant.user).where('name LIKE ?', "%#{
      Metrics::GamificationMetrics::AHOY_EVENT_NAMES[:PLANT_BROUGHT_TO_LIFE_PREFIX]
    }").or(Ahoy::Event.where(user: @plant.user).where('name LIKE ?', "%#{
      Metrics::GamificationMetrics::AHOY_EVENT_NAMES[:PLANT_REVIVED_FROM_DEATH_PREFIX]
    }")).or(Ahoy::Event.where(user: @plant.user).where('name LIKE ?', "%#{
      Metrics::GamificationMetrics::AHOY_EVENT_NAMES[:PLANT_DIED_PREFIX]
    }")).order(:time)

    return nil if plant_life_death_events.empty?

    plant_lifespans = calculate_plant_lifespans(plant_life_death_events)
    return nil if plant_lifespans.nil?

    average_plant_lifespan = plant_lifespans.inject { |sum, lifespan| sum + lifespan }.to_f / plant_lifespans.size
    ActiveSupport::Duration.build(average_plant_lifespan)
  end

  def update_plant_image(old_plant_stage_index)
    new_plant_image = PLANT_STAGE_IMAGES[@plant.plant_type.name][old_plant_stage_index]

    @plant.plant_image = new_plant_image
    @plant.save!
  end

  def plant_stage_index
    PLANT_STAGE_IMAGES[@plant.plant_type.name].find_index(@plant.plant_image)
  end

  private

  def can_plant_decay?
    if @plant.last_watered_at.nil? || Set[0, 4].include?(plant_stage_index)
      false
    else
      true
    end
  end

  def calculate_plant_lifespans(life_and_death_events)
    lifespans = []

    life_and_death_events.each_with_index do |event, index|
      if index.even?
        invalid_lifespan?(event)

        break if index == life_and_death_events.count - 1

        lifespan = life_and_death_events[index + 1].time - event.time
        lifespans.push(lifespan)
      else
        return nil unless event.name.include?(Metrics::GamificationMetrics::AHOY_EVENT_NAMES[:PLANT_DIED_PREFIX])
      end
    end

    if plant_alive?(life_and_death_events)
      lifespan = Time.zone.now - life_and_death_events.last.time
      lifespans.push(lifespan)
    end

    lifespans
  end

  def invalid_lifespan?(event)
    unless event.name.include?(Metrics::GamificationMetrics::AHOY_EVENT_NAMES[:PLANT_BROUGHT_TO_LIFE_PREFIX]) ||
           event.name.include?(Metrics::GamificationMetrics::AHOY_EVENT_NAMES[:PLANT_REVIVED_FROM_DEATH_PREFIX])
      nil
    end
  end

  def plant_alive?(life_and_death_events)
    life_and_death_events.last.name.include?(
      Metrics::GamificationMetrics::AHOY_EVENT_NAMES[:PLANT_BROUGHT_TO_LIFE_PREFIX]
    ) || life_and_death_events.last.name.include?(
      Metrics::GamificationMetrics::AHOY_EVENT_NAMES[:PLANT_REVIVED_FROM_DEATH_PREFIX]
    )
  end
end
