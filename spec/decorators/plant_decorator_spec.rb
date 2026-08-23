# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PlantDecorator do
  describe '#pot' do
    it 'returns the correct pot image for a new user' do
      expect(FactoryBot.create(:user).plant.decorate.pot).to eq('images/pots/square_default.webp')
    end
  end

  describe '#pot_lip' do
    let(:item) { FactoryBot.create(:pot_with_colour, image_url: image_path) }
    let(:plant) { FactoryBot.create(:plant, pot_type: item).decorate }

    it 'returns the correct pot lip path for a new user' do
      expect(FactoryBot.create(:user).plant.decorate.pot_lip).to eq('images/pots/lips/lip_default.webp')
    end

    context 'with a simple pot path' do
      let(:image_path) { 'images/pots/pot_blue.webp' }

      it 'returns the correct pot lip path, based on the colour of the pot' do
        expect(plant.pot_lip).to eq('images/pots/lips/lip_blue.webp')
      end
    end

    context 'with a complicated pot path containing multiple underscores' do
      let(:image_path) { 'images/pots/pot_square_red.webp' }

      it 'returns the correct pot lip path, based on the colour of the pot' do
        expect(plant.pot_lip).to eq('images/pots/lips/lip_red.webp')
      end
    end
  end
end
