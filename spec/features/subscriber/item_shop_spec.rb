# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Item Shop', type: :feature do
  let!(:subscriber) { FactoryBot.create(:user, role: 'subscriber', points: 150) }

  let!(:plant_items) do
    plant_items = FactoryBot.create_list(:plant_item, 5, price: 100)
    FactoryBot.create(:user_item, user: subscriber, item: plant_items[3])
    FactoryBot.create(:user_item, user: subscriber, item: plant_items[4])
    plant_items
  end

  let!(:pot_items) do
    pot_items = FactoryBot.create_list(:pot_item, 5, price: 50)
    FactoryBot.create(:user_item, user: subscriber, item: pot_items[3])
    FactoryBot.create(:user_item, user: subscriber, item: pot_items[4])
    pot_items
  end

  before do
    login_as subscriber, scope: :user
    visit subscriber_items_path
  end

  describe 'Viewing items in the Item Shop', :js do
    it 'can view the available items to buy in the Item Shop List' do
      expect(page).to have_content(plant_items[0].name)
      expect(page).to have_content(plant_items[1].name)
      expect(page).to have_content(plant_items[2].name)
      expect(page).to have_content(plant_items[3].name)
      expect(page).to have_content(plant_items[4].name)

      expect(page).to have_content(pot_items[0].name)
      expect(page).to have_content(pot_items[1].name)
      expect(page).to have_content(pot_items[2].name)
      expect(page).to have_content(pot_items[3].name)
      expect(page).to have_content(pot_items[4].name)

      expect(Item.exists?(name: 'Daisy Seed')).to be true
      expect(page).not_to have_content('Daisy Seed')

      expect(Item.exists?(name: 'Square Pot')).to be true
      expect(page).not_to have_content('Square Pot')
    end

    it 'can have the option to buy an unpurchased item in the Item Shop List', :js do
      click_on plant_items[0].name

      within(:css, '.shop-preview-section') do
        expect(page).to have_content('Purchase')
      end
    end

    it 'can not have the option to buy a purchased item in the Item Shop List' do
      click_on pot_items[3].name

      within(:css, '.shop-preview-section') do
        expect(page).not_to have_content('Purchase')
      end
    end
  end

  describe 'Spending Points Purchasing Items' do
    it 'can purchase an item successfully', :js do
      expect(find('#current_user_points')).to have_content('Points: 150', exact: true)

      card = find('.shop-section-card', text: plant_items[0].name)
      price = card.find('div', text: plant_items[0].name).sibling(class: 'card-text')
      expect(price).not_to have_content('SOLD', exact: true)

      click_on plant_items[0].name
      click_on 'Purchase'

      expect(find('#current_user_points')).to have_content('Points: 50', exact: true)

      card = find('.shop-section-card', text: plant_items[0].name)
      price = card.find('div', text: plant_items[0].name).sibling(class: 'card-text')
      expect(price).to have_content('SOLD', exact: true)

      expect(UserItem.exists?(item: plant_items[0], user: subscriber)).to be true
    end

    it 'can not purchase an item due to insufficient points', :js do
      click_on plant_items[0].name
      click_on 'Purchase'

      points = find('#current_user_points')

      click_on plant_items[1].name
      click_on 'Purchase'

      expect(page).to have_content('You do not have enough points to purchase this item.')
      expect(points.text).to eq(find('#current_user_points').text)

      card = find('.shop-section-card', text: plant_items[1].name)
      price = card.find('div', text: plant_items[1].name).sibling(class: 'card-text')
      expect(price).not_to have_content('SOLD', exact: true)

      within(:css, '.shop-preview-section') do
        expect(page).to have_content('Purchase')
      end

      expect(UserItem.exists?(item: plant_items[1], user: subscriber)).to be false
    end
  end
end
