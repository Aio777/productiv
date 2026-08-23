# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Subscriber::PlantsController', type: :request do
  let!(:subscriber) { FactoryBot.create(:user, role: 'subscriber') }

  before do
    FactoryBot.create(:item, category: 'invalid')
    login_as(subscriber, scope: :user)
  end

  describe 'PATCH /subscriber/plants/:id' do
    it "updates the plant based on the subscriber's choices", :js do
      new_plant = FactoryBot.create(
        :item,
        category: 'plant',
        image_url: 'images/plants/cactus_seed.webp',
        name: 'Cactus Seed'
      )
      new_pot = FactoryBot.create(
        :item,
        category: 'pot',
        image_url: 'images/pots/potion_green.webp',
        name: 'Green Potion Pot'
      )
      UserItem.create!(user: subscriber, item: new_plant)
      UserItem.create!(user: subscriber, item: new_pot)

      patch subscriber_plant_path(subscriber.plant),
            params: { plant: { plant_type_id: new_plant.id, pot_type_id: new_pot.id } }

      subscriber.reload

      expect(subscriber.plant.plant_type_id).to eq(new_plant.id)
      expect(subscriber.plant.pot_type_id).to eq(new_pot.id)

      get subscriber_root_path

      expect(response.body).to include('images/plants/cactus_seed')
      expect(response.body).to include('images/pots/potion_green')
    end

    it 'only permits plant_type_id and pot_type_id' do
      patch subscriber_plant_path(subscriber.plant), params: {
        plant: {
          plant_type_id: subscriber.user_items.first.item_id,
          pot_type_id: subscriber.user_items.second.item_id,
          malicious: 'hack'
        }
      }

      updated = subscriber.plant.reload

      expect(
        subscriber.user_items.find_by(
          item_id: subscriber.plant.plant_type_id
        ).item_id
      ).to eq(subscriber.user_items.first.item_id)

      expect(
        subscriber.user_items.find_by(
          item_id: subscriber.plant.pot_type_id
        ).item_id
      ).to eq(subscriber.user_items.second.item_id)
      expect { updated.malicious }.to raise_error(NoMethodError)
    end
  end
end
