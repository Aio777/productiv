class AddColumnPointsToTeamProjectMember < ActiveRecord::Migration[8.0]
  def change
    add_column :team_project_members, :points, :integer
  end
end
