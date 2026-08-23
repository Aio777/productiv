class CreateReviews < ActiveRecord::Migration[8.0]
  def change
    create_table :reviews do |t|
      t.integer :rating
      t.text :body
      t.integer :positive_interest_count, default: 0
      t.integer :negative_interest_count, default: 0
      t.boolean :hidden, default: false
      t.integer :review_index
      t.timestamps
      t.string :name
    end
  end
end
