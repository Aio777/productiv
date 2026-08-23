# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Plant watering performance', :js, type: :feature do
  let!(:subscriber) do
    FactoryBot.create(
      :user,
      role: 'subscriber',
      points: 100
    )
  end

  before do
    subscriber.plant.update!(
      plant_image: 'images/plants/daisy_halfgrown.webp',
      last_watered_at: nil
    )

    login_as(subscriber, scope: :user)
  end

  it 'waters the plant and updates growth in an acceptable time' do
    visit subscriber_root_path

    plant = subscriber.plant
    original_points = subscriber.points

    expect(plant.plant_image).to eq('images/plants/daisy_halfgrown.webp')

    expect do
      accept_confirm do
        click_button 'Water'
      end

      expect(page).to have_content('Plant has been successfully watered!')

      plant.reload
      subscriber.reload

      expect(plant.plant_image).to eq('images/plants/daisy_fullgrown.webp')
      expect(plant.last_watered_at).to be_present
      expect(subscriber.points).to be < original_points
    end.to perform_under(2000).ms
  end
end
