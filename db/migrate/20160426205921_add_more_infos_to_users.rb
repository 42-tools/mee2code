class AddMoreInfosToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :user_info_shorts, :phone, :string
    add_column :user_info_shorts, :image_url, :string
    add_column :user_info_shorts, :pool_month, :string
    add_column :user_info_shorts, :pool_year, :string
  end
end
