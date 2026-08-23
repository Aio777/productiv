class ChangeColumnStatusToBoolean < ActiveRecord::Migration[8.0]
  def change
    remove_column :team_project_tasks, :status
    add_column :team_project_tasks, :status, :boolean, default: false, null: false

    remove_column :individual_tasks, :status
    add_column :individual_tasks, :status, :boolean, default: false, null: false
  end
end