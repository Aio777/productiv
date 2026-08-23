# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Poro::Plant do
  let(:plant) { create(:plant) }
  let(:plant_poro) { described_class.new(plant) }

  # Poro::Plant.create_active_record_plant runs in the after_create hook for the User model.
  describe '.create_active_record_plant' do
    it 'creates a simple plant for a user' do
      subscriber = FactoryBot.create(:user, role: 'subscriber')

      expect(subscriber.user_items.count).to eq(2)
      expect(subscriber.user_items.first.item.name).to eq('Daisy Seed')
      expect(subscriber.user_items.second.item.name).to eq('Square Pot')
      expect(subscriber.plant.plant_type).to eq(subscriber.user_items.first.item)
      expect(subscriber.plant.plant_image).to eq(subscriber.user_items.first.item.image_url)
      expect(subscriber.plant.pot_type).to eq(subscriber.user_items.second.item)
    end

    it 'does not create a plant for a non-subscriber user' do
      reporter = FactoryBot.create(:user, role: 'reporter')

      expect(reporter.user_items.count).to eq(0)
      expect(reporter.plant).to be_nil

      expect { described_class.create_active_record_plant(reporter) }.to raise_error(Poro::Plant::NonSubscriberError)
    end
  end

  describe '#water' do
    it 'does not grow plant if the plant is fully grown' do
      plant.plant_image = 'images/plants/daisy_fullgrown.webp'

      expect(plant_poro.water).to be(false)
      expect(plant_poro.plant.plant_image).to eq('images/plants/daisy_fullgrown.webp')
    end

    it 'grows plant from a seed to fully grown' do
      plant.plant_image = 'images/plants/daisy_seed.webp'

      expect(plant_poro.water).to be(true)
      expect(plant_poro.plant.plant_image).to eq('images/plants/daisy_halfgrown.webp')

      expect(plant_poro.water).to be(true)
      expect(plant_poro.plant.plant_image).to eq('images/plants/daisy_fullgrown.webp')
    end

    it 'reverses decay from a dead plant to a fully grown plant' do
      plant.plant_image = 'images/plants/daisy_dead.webp'

      expect(plant_poro.water).to be(true)
      expect(plant_poro.plant.plant_image).to eq('images/plants/daisy_decay.webp')

      expect(plant_poro.water).to be(true)
      expect(plant_poro.plant.plant_image).to eq('images/plants/daisy_fullgrown.webp')
    end
  end

  describe '#decay' do
    it 'does not decay plant if it is a seed (has not been watered)' do
      plant.plant_image = 'images/plants/daisy_seed.webp'

      expect(plant_poro.decay).to be(false)
      expect(plant_poro.plant.plant_image).to eq('images/plants/daisy_seed.webp')
    end

    it 'does not decay plant if it is dead' do
      plant.plant_image = 'images/plants/daisy_dead.webp'
      plant.last_watered_at = 1.month.ago

      expect(plant_poro.decay).to be(false)
      expect(plant_poro.plant.plant_image).to eq('images/plants/daisy_dead.webp')
    end

    it 'decays plant to dead if the plant has not been watered in over a week' do
      plant.plant_image = 'images/plants/daisy_fullgrown.webp'
      plant.last_watered_at = 3.weeks.ago

      expect(plant_poro.decay).to be(true)
      expect(plant_poro.plant.plant_image).to eq('images/plants/daisy_dead.webp')

      plant.plant_image = 'images/plants/daisy_halfgrown.webp'
      expect(plant_poro.decay).to be(true)
      expect(plant_poro.plant.plant_image).to eq('images/plants/daisy_dead.webp')

      plant.plant_image = 'images/plants/daisy_decay.webp'
      expect(plant_poro.decay).to be(true)
      expect(plant_poro.plant.plant_image).to eq('images/plants/daisy_dead.webp')
    end

    it 'decays plant from fully grown to decayed to dead' do
      plant.plant_image = 'images/plants/daisy_fullgrown.webp'
      plant.last_watered_at = 4.days.ago

      expect(plant_poro.decay).to be(true)
      expect(plant_poro.plant.plant_image).to eq('images/plants/daisy_decay.webp')

      expect(plant_poro.decay).to be(false)
      expect(plant_poro.plant.plant_image).to eq('images/plants/daisy_decay.webp')

      plant.last_watered_at = 2.weeks.ago
      expect(plant_poro.decay).to be(true)
      expect(plant_poro.plant.plant_image).to eq('images/plants/daisy_dead.webp')
    end
  end

  describe '#calculate_average_plant_streak' do
    let(:plants) { FactoryBot.create_list(:plant, 3) }

    it 'returns nil when no plants have any data for calculating streaks' do
      expect(plants.count).to eq(3)
      expect(plant_poro.calculate_average_plant_streak).to be_nil
    end

    context 'with multiple plant lifespans' do
      let(:plant) { plants[0] }
      let(:plant_poro) { described_class.new(plant) }
      let(:date) { DateTime.parse('2026-01-01 09:00:00') }

      before do
        FactoryBot.create(
          :ahoy_event,
          name: Metrics::GamificationMetrics::AHOY_EVENT_NAMES[:PLANT_BROUGHT_TO_LIFE_PREFIX],
          user: plants[0].user,
          time: date
        )
        FactoryBot.create(
          :ahoy_event,
          name: Metrics::GamificationMetrics::AHOY_EVENT_NAMES[:PLANT_DIED_PREFIX],
          user: plants[0].user,
          time: date + 1.day
        )
        FactoryBot.create(
          :ahoy_event,
          name: Metrics::GamificationMetrics::AHOY_EVENT_NAMES[:PLANT_REVIVED_FROM_DEATH_PREFIX],
          user: plants[0].user,
          time: date + 2.days
        )
        FactoryBot.create(
          :ahoy_event,
          name: Metrics::GamificationMetrics::AHOY_EVENT_NAMES[:PLANT_DIED_PREFIX],
          user: plants[0].user,
          time: date + 7.days
        )
      end

      it 'displays the correct average plant streak' do
        expect(plant_poro.calculate_average_plant_streak).to eq(3.days)
      end

      it 'displays no average plant streak when the plant lifespans are incorrect' do
        FactoryBot.create(
          :ahoy_event,
          name: Metrics::GamificationMetrics::AHOY_EVENT_NAMES[:PLANT_REVIVED_FROM_DEATH_PREFIX],
          user: plants[0].user,
          time: date + 3.days
        )
        expect(plant_poro.calculate_average_plant_streak).to be_nil
      end
    end
  end

  describe '#update_plant_image' do
    it 'correctly updates the plant image' do
      new_plant_type = FactoryBot.create(
        :plant_item,
        name: 'Hyacinth Seed',
        image_url: 'images/plants/hyacinth_seed.webp'
      )

      new_pot = FactoryBot.create(:pot_item, image_url: 'images/pots/triangle_yellow.webp')

      plant = FactoryBot.create(:plant, plant_image: 'images/plants/daisy_fullgrown.webp')
      plant_poro = described_class.new(plant)

      FactoryBot.create(:user_item, user: plant.user, item: new_plant_type)
      FactoryBot.create(:user_item, user: plant.user, item: new_pot)

      plant.plant_type = new_plant_type
      plant.pot_type = new_pot

      expect(plant_poro.plant.plant_image).to eq('images/plants/daisy_fullgrown.webp')

      plant_poro.update_plant_image(2)
      expect(plant_poro.plant.plant_image).to eq('images/plants/hyacinth_fullgrown.webp')
    end
  end

  describe '#plant_stage_index' do
    it 'correctly returns the correct stage index of a plant image for a new user' do
      expect(plant_poro.plant_stage_index).to eq(0)
    end

    it 'correctly returns the correct stage index of a plant image for an existing user' do
      hyacinth_plant_item = FactoryBot.create(:plant_item, name: 'Hyacinth Seed')
      plant.plant_type = hyacinth_plant_item
      plant.plant_image = 'images/plants/hyacinth_decay.webp'

      expect(plant_poro.plant_stage_index).to eq(3)
    end
  end
end
