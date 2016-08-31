class AddCompusIdColumnToUserHistory < ActiveRecord::Migration[5.0]
  def change
    add_column :user_histories, :primary, :boolean
    add_column :user_histories, :campus_id, :integer
  end
end
