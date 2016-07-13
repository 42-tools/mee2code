class AddCursusColumnToUserInfoShort < ActiveRecord::Migration[5.0]
  def change
    add_column :user_info_shorts, :cursus, :string
  end
end
