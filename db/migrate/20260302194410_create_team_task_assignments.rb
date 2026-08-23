class CreateTeamTaskAssignments < ActiveRecord::Migration[8.0]
  def change
    create_table :team_task_assignments do |t|
      t.references :team_project_task, null: false, foreign_key: { to_table: :team_project_tasks }
      t.references :user, null: false, foreign_key: { to_table: :users }
      t.timestamps
    end
  end
end
