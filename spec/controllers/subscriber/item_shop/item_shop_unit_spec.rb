# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Subscriber::ItemShop', type: :request do
  let!(:subscriber) { create(:user, role: 'subscriber', points: 50) }

  before do
    FactoryBot.create_list(:plant_item, 5)
    FactoryBot.create_list(:pot_item, 4)
    login_as(subscriber, scope: :user)
  end

  # subscriber/item_shop#index
  describe 'GET /subscriber/items' do
    it 'shows a list of items in the item shop' do
      get subscriber_items_path

      expect(response).to render_template(:index)
      expect(response.body).to include('Plants')
      expect(response.body).to include('Pot Shapes')
    end
  end

  # subscriber/item_shop#show
  describe 'GET /subscriber/item/:id' do
    it 'shows an individual item' do
      pot_item = FactoryBot.create(:pot_item, name: 'Sunflower Seed')
      get subscriber_item_path(pot_item), headers: { 'Turbo-Frame' => 'item_preview' }
      expect(response).to render_template(:show)
      expect(response.body).to include('Sunflower Seed')
      expect(response.body).to include('Purchase')
    end
  end

  # subscriber/item_shop#create
  describe 'POST /subscriber/user_items' do
    it 'successfully purchases an item for a user' do
      pot_item = FactoryBot.create(:pot_item, name: 'Sunflower Seed', price: 30)

      expect do
        post subscriber_user_items_path, params: { user_item: { item_id: pot_item.id.to_s } }
      end.to change(UserItem, :count).by(1)
    end

    it 'fails to purchase an item for a user due to insufficient points' do
      pot_item = FactoryBot.create(:pot_item, name: 'Sunflower Seed', price: 60)

      expect do
        post subscriber_user_items_path, params: { user_item: { item_id: pot_item.id.to_s } }
      end.not_to change(UserItem, :count)
    end

    it 'fails to purchase an item for a user due to the item already being purchased' do
      pot_item = FactoryBot.create(:pot_item, name: 'Sunflower Seed', price: 20)
      FactoryBot.create(:user_item, user: subscriber, item: pot_item)

      expect do
        post subscriber_user_items_path, params: { user_item: { item_id: pot_item.id.to_s } }
      end.not_to change(UserItem, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  # subscriber/item_shop#turbo_response
  describe 'private turbo_response' do
    it 'updates the item preview and item lists after purchasing an item' do
      pot_item = FactoryBot.create(:pot_item, name: 'Sunflower Seed', price: 20)
      post subscriber_user_items_path,
           params: { user_item: { item_id: pot_item.id.to_s } },
           headers: { 'Accept' => 'text/vnd.turbo-stream.html' }

      subscriber.reload
      expect(subscriber.points).to eq(30)

      expect(response.body).to include('Item has been successfully purchased!')
      expect(response.body).not_to include('Purchase')
      expect(response.body).to include('SOLD')
    end

    it 'does not update the item preview and item lists after failing to purchase an item due to insufficient points' do
      pot_item = FactoryBot.create(:pot_item, name: 'Sunflower Seed', price: 60)
      post subscriber_user_items_path,
           params: { user_item: { item_id: pot_item.id.to_s } },
           headers: { 'Accept' => 'text/vnd.turbo-stream.html' }

      subscriber.reload
      expect(subscriber.points).to eq(50)

      expect(response.body).to include('You do not have enough points to purchase this item.')
      expect(response.body).to include('Purchase')
      expect(response.body).not_to include('SOLD')
    end
  end
end
