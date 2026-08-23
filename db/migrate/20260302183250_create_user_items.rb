class CreateUserItems < ActiveRecord::Migration[8.0]
  def change
    create_table :user_items do |t|
      t.references :user, null: false, foreign_key: { to_table: :users }
      t.references :item, null: false, foreign_key: { to_table: :items }
      t.timestamps
    end
  end
end
