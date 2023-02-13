class AddUserRoleToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :user_role, :integer, default: 1, null: false
  end
end
