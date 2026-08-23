class AddPlantImageToPlants < ActiveRecord::Migration[8.0]
  def change
    add_column :plants, :plant_image, :string
  end
end
