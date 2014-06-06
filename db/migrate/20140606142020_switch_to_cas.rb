class SwitchToCas < ActiveRecord::Migration
  def up
    remove_column :users, :encrypted_password
  end
  def down
    add_column :users, :encrypted_password, default: "", null: false
  end
end
