class RenameColumnStatusToStatusComplete < ActiveRecord::Migration[8.0]
  def change
    rename_column :team_project_tasks, :status, :status_complete
    rename_column :individual_tasks, :status, :status_complete
  end
end
