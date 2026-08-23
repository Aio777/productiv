class AddImagePathToTeamProjects < ActiveRecord::Migration[8.0]
  def change
    add_column :team_projects, :image_path, :string
  end
end
