class CreateUserInfoShorts < ActiveRecord::Migration
  def change
    create_table :user_info_shorts do |t|
      t.references :user, index: true, foreign_key: true
      t.string :login
      t.string :display_name

      t.timestamps null: false
    end
  end
end
