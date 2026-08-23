class CreateUnconfiguredUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :unconfigured_users do |t|
      t.references :user, null: false, foreign_key: { to_table: :users }
      t.string :email, null: false

      t.timestamps
    end
  end
end

