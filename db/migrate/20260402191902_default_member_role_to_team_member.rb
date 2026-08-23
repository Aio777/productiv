class DefaultMemberRoleToTeamMember < ActiveRecord::Migration[8.0]
  def change
    change_column_default :team_project_members, :role, "team_member"
  end
end
