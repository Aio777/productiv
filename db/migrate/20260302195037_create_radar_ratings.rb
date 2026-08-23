class CreateRadarRatings < ActiveRecord::Migration[8.0]
  def change
    create_table :radar_ratings do |t|
      t.references :radar_category, null: false, foreign_key: { to_table: :radar_categories }
      t.references :user, null: false, foreign_key: { to_table: :users }
      t.references :team_project, null: false, foreign_key: { to_table: :team_projects }
      t.integer :category_rating
      t.string :category_assessment
      t.timestamps
    end
  end
end
