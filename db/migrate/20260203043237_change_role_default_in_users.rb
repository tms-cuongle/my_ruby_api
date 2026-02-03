class ChangeRoleDefaultInUsers < ActiveRecord::Migration[8.1]
  def change
    change_column_default :users, :role, from: nil, to: 1
    User.update_all(role: 1) if User.any?
  end
end
