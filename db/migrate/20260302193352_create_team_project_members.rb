class CreateTeamProjectMembers < ActiveRecord::Migration[8.0]
  def change
    create_table :team_project_members do |t|
      t.references :team_project, null: false, foreign_key: { to_table: :team_projects }
      t.references :user, null: false, foreign_key: { to_table: :users }
      t.string :role, default: "member"
      t.datetime :joined_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }
      t.boolean :leaderboard_visibility, default: true
      t.timestamps
    end
  end
end
