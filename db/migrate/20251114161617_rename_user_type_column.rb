class RenameUserTypeColumn < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :first_name, :string, default: "" 

    add_column :users, :last_name, :string, default: "" 

    add_column :users, :role, :string, default: "signee" 

    add_column :users, :registration_ip, :string 
  end
end
