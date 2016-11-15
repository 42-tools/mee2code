class AddRoleColumnToUserInfos < ActiveRecord::Migration[5.0]
  def change
    add_column :user_infos, :role, :integer, default: 0
  end
end
