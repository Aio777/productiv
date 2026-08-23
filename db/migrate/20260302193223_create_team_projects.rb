class CreateTeamProjects < ActiveRecord::Migration[8.0]
  def change
    create_table :team_projects do |t|
      t.string :name
      t.string :description
      t.boolean :leaderboard_visible, default: true
      t.timestamps
    end
  end
end
