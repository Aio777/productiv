class AddLayoutToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :layout, :integer
  end
end
