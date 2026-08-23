class AddColumnPointsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :points, :integer, default: 0, null: false
    add_column :users, :last_watered_at, :datetime
  end
end
