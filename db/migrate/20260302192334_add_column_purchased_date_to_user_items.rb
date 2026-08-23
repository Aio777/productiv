class AddColumnPurchasedDateToUserItems < ActiveRecord::Migration[8.0]
  def change
    add_column :user_items, :purchased_at, :datetime
  end
end
