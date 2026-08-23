# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Plant Images', type: :feature do
  let!(:subscriber1) { FactoryBot.create(:user, role: 'subscriber', first_name: 'subscriber1', last_name: 'user1') }

  before do
    login_as(subscriber1, scope: :user)
    seed_shop_items
  end

  describe 'in the Item Shop' do
    it 'loads upon visiting page in an acceptable time' do
      expect do
        visit subscriber_items_path

        expect(page).to have_css('.shop-section-plant-img', minimum: 24)
        expect(page).to have_css('.shop-section-pot-img', minimum: 24)
        expect(page).to have_content('Performance Plant 024 Seed')
        expect(page).to have_content('Performance Pot 024')
      end.to perform_under(1500).ms
    end

    it 'load upon clicking on an item to preview in an acceptable time', :js do
      visit subscriber_items_path

      expect(page).to have_css('turbo-frame#item_preview')
      expect(page).to have_css('.shop-grid-wrapper', minimum: 2)
      expect(page).to have_css('.shop-section-plant-img', minimum: 24)
      expect(page).to have_css('.shop-section-pot-img', minimum: 24)

      plant_section = all('.shop-grid-wrapper').first
      plant_link = plant_section.first('a.col-md')

      expect do
        plant_link.click

        within('turbo-frame#item_preview') do
          expect(page).to have_css('img')
          expect(page).to have_content('Price:')
          expect(page).to have_content('points')
        end
      end.to perform_under(1200).ms
    end
  end

  def seed_shop_items
    current_time = Time.current

    Item.insert_all(
      24.times.map do |index|
        item_number = index + 1

        {
          name: "Performance Plant #{item_number.to_s.rjust(3, '0')} Seed",
          category: 'plant',
          description: "Performance plant #{item_number}",
          price: 10 + item_number,
          image_url: 'images/plants/daisy_seed.webp',
          created_at: current_time,
          updated_at: current_time
        }
      end
    )

    Item.insert_all(
      24.times.map do |index|
        item_number = index + 1

        {
          name: "Performance Pot #{item_number.to_s.rjust(3, '0')}",
          category: 'pot',
          description: "Performance pot #{item_number}",
          price: 20 + item_number,
          image_url: 'images/pots/square_default.webp',
          created_at: current_time,
          updated_at: current_time
        }
      end
    )
  end
end
