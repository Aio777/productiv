class SwapReferenceUserForMember < ActiveRecord::Migration[8.0]
  def change
    remove_reference :radar_ratings, :user, foreign_key: true
    add_reference :radar_ratings, :team_project_member, foreign_key: true
  end
end
