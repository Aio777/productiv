class AddTableNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.references :shared_invite, foreign_key: true
      t.references :team_project_task, foreign_key: true
      t.references :individual_task, foreign_key: true

      t.string :message, null: false
      t.boolean :read, default: false, null: false

      t.timestamps
    end
  end
end
