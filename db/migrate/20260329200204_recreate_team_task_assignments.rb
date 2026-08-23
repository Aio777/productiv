class RecreateTeamTaskAssignments < ActiveRecord::Migration[8.0]
  def change
    drop_table :team_task_assignments do |t|
      t.bigint "team_project_task_id", null: false
      t.bigint "user_id", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    create_table :team_task_assignments do |t|
      t.references :team_project_task, null: false, foreign_key: true
      t.references :team_project_member, null: false, foreign_key: true
      t.timestamps
    end

    add_index :team_task_assignments,
              [:team_project_task_id, :team_project_member_id],
              unique: true,
              name: "index_team_task_assignments_on_task_and_member"
  end
end