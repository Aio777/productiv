# frozen_string_literal: true

# == Schema Information
#
# Table name: plants
#
#  id              :bigint           not null, primary key
#  last_watered_at :datetime
#  plant_image     :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  plant_type_id   :bigint           not null
#  pot_type_id     :bigint           not null
#  user_id         :bigint           not null
#
# Indexes
#
#  index_plants_on_plant_type_id  (plant_type_id)
#  index_plants_on_pot_type_id    (pot_type_id)
#  index_plants_on_user_id        (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (plant_type_id => items.id)
#  fk_rails_...  (pot_type_id => items.id)
#  fk_rails_...  (user_id => users.id)
#
class Plant < ApplicationRecord
  belongs_to :user

  belongs_to :plant_type, class_name: 'Item'
  belongs_to :pot_type, class_name: 'Item'
end
