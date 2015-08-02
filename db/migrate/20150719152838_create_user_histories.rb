class CreateUserHistories < ActiveRecord::Migration
  def change
    create_table :user_histories do |t|
      t.string :login
      t.string :location
      t.datetime :date_begin
      t.datetime :date_end

      t.timestamps null: false
    end
  end
end
