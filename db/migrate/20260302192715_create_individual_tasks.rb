class CreateIndividualTasks < ActiveRecord::Migration[8.0]
  def change
    create_table :individual_tasks do |t|
      t.references :individual_project, null: false, foreign_key: { to_table: :individual_projects }
      t.string :name
      t.string :description
      t.datetime :due_date, null: false
      t.datetime :reminder_date
      t.string :status, default: "incomplete"
      t.string :difficulty
      t.boolean :read
      t.integer :points
      t.timestamps
    end
  end
end
