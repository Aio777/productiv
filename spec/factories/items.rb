# == Schema Information
#
# Table name: items
#
#  id          :bigint           not null, primary key
#  category    :string
#  description :string
#  image_url   :string
#  name        :string
#  price       :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
FactoryBot.define do
  factory :item do
    factory :base_plant_item do
      name { 'Daisy Seed' }
      category { 'plant' }
      image_url { 'images/plants/daisy_seed.webp' }
      price { 0 }
    end

    factory :plant_item do
      sequence(:name) { |n| "Plant ##{n} Seed" }
      category { 'plant' }
      image_url { 'images/plants/daisy_seed.webp' }
      price { rand(10..100) }
    end

    factory :base_pot_item do
      name { 'Square Pot' }
      category { 'pot' }
      image_url { 'images/pots/square_default.webp' }
      price { 0 }
    end

    factory :pot_item do
      sequence(:name) { |n| "Pot ##{n} Pot" }
      category { 'pot' }
      image_url { 'images/pots/square_default.webp' }
      price { rand(10..100) }
    end

    factory :pot_with_colour do
      name { 'Square Pot' }
      category { 'pot' }
      image_url { 'images/pots/square_green.webp' }
      price { 0 }
    end
  end
end
