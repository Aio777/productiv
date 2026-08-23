class AddColumnPlantStageToPlants < ActiveRecord::Migration[8.0]
  def change
    add_column :plants, :plant_stage, :string, default: "seedling"
  end
end
