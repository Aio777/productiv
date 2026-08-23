class RemoveLastWateredAtFromUsers < ActiveRecord::Migration[8.0]
  def change
    remove_column :users, :last_watered_at, :datetime
  end
end
