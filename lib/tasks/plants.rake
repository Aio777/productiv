# frozen_string_literal: true

namespace :plants do
  desc 'Update the plant image for each subscriber, decaying the plant if sufficient time has elapsed.'
  task check_plant_decay: :environment do
    Plant.all.each do |plant|
      Poro::Plant.new(plant).decay
    end
  end
end
