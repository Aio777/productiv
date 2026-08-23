# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Poro::Subscriber do
  let(:user) { create(:user, role: 'subscriber', points: 17) }
  let(:subscriber_poro) { described_class.new(user) }

  describe '#set_user_items' do
    it 'retrieves the default items for a new user' do
      expect(subscriber_poro.set_user_items).to match(
        { plant_items: [['Daisy Seed', an_instance_of(Integer)]], pot_items: [['Square Pot', an_instance_of(Integer)]] }
      )
    end

    it 'retrieves the items an existing user owns who has several non-default items' do
      FactoryBot.create(:user_item, user: user, item: FactoryBot.create(:plant_item, name: 'Sunflower Seed'))
      FactoryBot.create(:user_item, user: user, item: FactoryBot.create(:plant_item, name: 'Tomato Seed'))
      FactoryBot.create(:user_item, user: user, item: FactoryBot.create(:pot_item, name: 'Red Diamond Pot'))
      FactoryBot.create(:user_item, user: user, item: FactoryBot.create(:pot_item, name: 'Green Moss Pot'))
      FactoryBot.create(:user_item, user: user, item: FactoryBot.create(:pot_item, name: 'Brown Dirt Pot'))

      expect(subscriber_poro.set_user_items.count).to eq(2)
      expect(subscriber_poro.set_user_items[:plant_items].to_h).to match(
        { 'Daisy Seed' => an_instance_of(Integer), 'Sunflower Seed' => an_instance_of(Integer),
          'Tomato Seed' => an_instance_of(Integer) }
      )
      expect(subscriber_poro.set_user_items[:pot_items].to_h).to match(
        { 'Square Pot' => an_instance_of(Integer), 'Red Diamond Pot' => an_instance_of(Integer),
          'Green Moss Pot' => an_instance_of(Integer), 'Brown Dirt Pot' => an_instance_of(Integer) }
      )
    end
  end

  describe '#can_afford_to_water_plant?' do
    it 'returns true for a normal user points value' do
      expect(subscriber_poro.can_afford_to_water_plant?).to be true
    end

    it 'returns true for a user points value that is the minimum allowed value' do
      user.points = 10
      expect(subscriber_poro.can_afford_to_water_plant?).to be true
    end

    it 'returns false for a user points value that is too low' do
      user.points = 8
      expect(subscriber_poro.can_afford_to_water_plant?).to be false
    end
  end

  describe '#pay_to_water_plant' do
    it 'successfully deducts points from a user' do
      subscriber_poro.pay_to_water_plant
      expect(subscriber_poro.user.points).to eq(7)
    end

    it 'does not deduct points from a user if the user does not have enough points' do
      user.points = 1
      expect { subscriber_poro.pay_to_water_plant }.to raise_error(Poro::Subscriber::InsufficientPointsForWateringPlantError)
    end
  end

  describe '#purchase_item' do
    let(:item) { FactoryBot.create(:plant_item, price: 15) }

    it 'successfully purchases an item' do
      subscriber_poro.purchase_item(item)
      expect(user.points).to eq(2)
    end

    it 'fails to purchase an item because of insufficient points' do
      expensive_item = FactoryBot.create(:plant_item, price: 20)

      expect { subscriber_poro.purchase_item(expensive_item) }.to raise_error(Poro::Subscriber::InsufficientPointsForBuyingItem)
    end
  end

  describe '#dashboard_data' do
    context 'when layout value is correct, it return returns correct graph data' do
      it 'returns nothing when value is invalid' do
        user.layout = 20
        expect { subscriber_poro.dashboard_data }.to raise_error(Poro::Subscriber::InvalidLayoutValueError)
      end

      it 'returns nothing when value is 0' do
        user.layout = 0
        expect(subscriber_poro.dashboard_data).to eq([])
      end

      it 'returns one set of graph data with valid value' do
        user.layout = 1
        expect(subscriber_poro.dashboard_data.size).to eq(1)
      end

      it 'returns multiple sets of graph data with valid value' do
        user.layout = 15
        expect(subscriber_poro.dashboard_data.size).to eq(4)
      end
    end
  end
end
