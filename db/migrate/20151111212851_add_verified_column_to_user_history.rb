class AddVerifiedColumnToUserHistory < ActiveRecord::Migration
  def change
    add_column :user_histories, :verified, :boolean
  end
end
