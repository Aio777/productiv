# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Plants customisation performance', :js, type: :feature do
  let!(:subscriber) do
    FactoryBot.create(
      :user,
      role: 'subscriber',
      first_name: 'Plant',
      last_name: 'Tester'
    )
  end

  let!(:hyacinth_seed) do
    Item.find_or_create_by!(name: 'Hyacinth Seed', category: 'plant') do |item|
      item.image_url = 'images/plants/hyacinth_seed.webp'
    end
  end

  let!(:green_square_pot) do
    Item.find_or_create_by!(name: 'Green Square Pot', category: 'pot') do |item|
      item.image_url = 'images/pots/square_green.webp'
    end
  end

  before do
    login_as(subscriber, scope: :user)

    subscriber.user_items.find_or_create_by!(item: hyacinth_seed)
    subscriber.user_items.find_or_create_by!(item: green_square_pot)
    seed_extra_owned_items
  end

  def sidebar_plant_image_src
    find("turbo-frame#sidebar_plant img[src*='plants']", match: :first)[:src]
  end

  def open_customise_modal
    find("[data-bs-target='#customisePlantModal']").click
    expect(page).to have_css('#customisePlantModal.show')
  end

  it 'loads the plant customisation controls in an acceptable time' do
    expect do
      visit subscriber_root_path

      expect(page).to have_css('turbo-frame#sidebar_plant')
      expect(page).to have_css("[data-bs-target='#customisePlantModal']")
      expect(page).to have_css('#customisePlantModal', visible: :all)
      expect(page).to have_select('Plant', visible: :all)
      expect(page).to have_select('Pot', visible: :all)
      expect(page).to have_css('option', text: 'Performance Plant 020 Seed', visible: :all)
      expect(page).to have_css('option', text: 'Performance Pot 020', visible: :all)
    end.to perform_under(1200).ms
  end

  it 'updates the plant customisation from the modal in an acceptable time' do
    visit subscriber_root_path
    original_src = sidebar_plant_image_src

    open_customise_modal

    select 'Hyacinth Seed', from: 'Plant'
    select 'Green Square Pot', from: 'Pot'

    expect(page).to have_select('Plant', selected: 'Hyacinth Seed')
    expect(page).to have_select('Pot', selected: 'Green Square Pot')

    expect do
      click_button 'Save'

      expect(page).to have_css("turbo-frame#sidebar_plant img[src*='hyacinth_seed']")

      updated_src = sidebar_plant_image_src
      expect(updated_src).not_to eq(original_src)
      expect(updated_src).to include('hyacinth_seed')
    end.to perform_under(1500).ms
  end

  def seed_extra_owned_items
    current_time = Time.current

    item_rows = 20.times.flat_map do |index|
      item_number = (index + 1).to_s.rjust(3, '0')

      [
        {
          name: "Performance Plant #{item_number} Seed",
          category: 'plant',
          description: "Performance plant #{item_number}",
          price: 10,
          image_url: 'images/plants/daisy_seed.webp',
          created_at: current_time,
          updated_at: current_time
        },
        {
          name: "Performance Pot #{item_number}",
          category: 'pot',
          description: "Performance pot #{item_number}",
          price: 10,
          image_url: 'images/pots/square_default.webp',
          created_at: current_time,
          updated_at: current_time
        }
      ]
    end

    Item.insert_all(item_rows)

    UserItem.insert_all(
      Item.where(name: item_rows.pluck(:name)).pluck(:id).map do |item_id|
        {
          user_id: subscriber.id,
          item_id: item_id,
          created_at: current_time,
          updated_at: current_time,
          purchased_at: current_time
        }
      end
    )
  end
end
