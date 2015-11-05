class CreateUserHistories < ActiveRecord::Migration
  def change
    create_table :user_histories do |t|
      t.references :user, index: true, foreign_key: true
      t.string :host
      t.datetime :begin_at
      t.datetime :end_at

      t.timestamps null: false
    end
  end
end
