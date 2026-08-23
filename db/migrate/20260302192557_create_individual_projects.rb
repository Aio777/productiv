class CreateIndividualProjects < ActiveRecord::Migration[8.0]
  def change
    create_table :individual_projects do |t|
      t.references :user, null: false, foreign_key: { to_table: :users }
      t.string :name
      t.timestamps
    end
  end
end
