class AddColumnWasSubscriberToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :was_subscriber, :boolean, null: false, default: true
  end
end
