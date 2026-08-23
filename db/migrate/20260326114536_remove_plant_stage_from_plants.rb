class RemovePlantStageFromPlants < ActiveRecord::Migration[8.0]
  def change
    remove_column :plants, :plant_stage, :string
  end
end
