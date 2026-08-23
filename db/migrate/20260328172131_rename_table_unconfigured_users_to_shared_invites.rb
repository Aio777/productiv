class RenameTableUnconfiguredUsersToSharedInvites < ActiveRecord::Migration[8.0]
  def change
    remove_reference :unconfigured_users, :user, foreign_key: true

    rename_table :unconfigured_users, :shared_invites

    add_reference :shared_invites, :team_project, null: false, foreign_key: true
  end
end
