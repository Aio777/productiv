class CreatePosts < ActiveRecord::Migration[8.0]
  def change
    create_table :posts do |t|
      t.references :parent, foreign_key: { to_table: :posts }, null: true
      t.boolean :answer_by_admin, default: false
      t.boolean :hidden, default: false
      t.integer :interest_count, default: 0
      t.string :title
      t.text :body
      t.timestamps
    end
  end
end