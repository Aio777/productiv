class CreatePlants < ActiveRecord::Migration[8.0]
  def change
    create_table :plants do |t|
      t.references :user, null: false, foreign_key: { to_table: :users }
      t.datetime :last_watered_at
      t.references :plant_type, null: false, foreign_key: {to_table: :items}
      t.references :pot_type, null: false, foreign_key: {to_table: :items}
      t.timestamps
    end
  end
end
