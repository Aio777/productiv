class CreateTeamProjectTasks < ActiveRecord::Migration[8.0]
  def change
    create_table :team_project_tasks do |t|
      t.references :team_project, null: false, foreign_key: { to_table: :team_projects }
      t.string :name
      t.string :description
      t.datetime :due_date, null: false
      t.datetime :reminder_date
      t.string :status, default: "incomplete"
      t.string :difficulty
      t.integer :points
      t.boolean :read
      t.timestamps
    end
  end
end
