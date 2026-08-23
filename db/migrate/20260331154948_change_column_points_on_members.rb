class ChangeColumnPointsOnMembers < ActiveRecord::Migration[8.0]
  def change
    remove_column :team_project_members, :points
    add_column :team_project_members, :points, :integer, default: 0, null: false
  end
end
