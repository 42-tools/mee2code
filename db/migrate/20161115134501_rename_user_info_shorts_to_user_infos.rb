class RenameUserInfoShortsToUserInfos < ActiveRecord::Migration[5.0]
  def change
    rename_table :user_info_shorts, :user_infos
  end
end
