# frozen_string_literal: true

class PlantDecorator < Draper::Decorator
  delegate_all

  def pot
    pot_type.image_url
  end

  def pot_lip
    colour = File.basename(pot_type.image_url, '.webp').split('_').last
    "images/pots/lips/lip_#{colour}.webp"
  end
end
