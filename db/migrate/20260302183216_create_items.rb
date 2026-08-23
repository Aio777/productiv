class CreateItems < ActiveRecord::Migration[8.0]
  def change
    create_table :items do |t|
      t.string :name
      t.integer :price
      t.string :description
      t.string :image_url
      t.string :category
      t.timestamps
    end
  end
end
