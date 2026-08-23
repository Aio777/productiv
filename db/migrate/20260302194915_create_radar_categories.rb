class CreateRadarCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :radar_categories do |t|
      t.references :team_project, null: false, foreign_key: { to_table: :team_projects }
      t.string :name
      t.timestamps
    end
  end
end
