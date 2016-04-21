class UserFriend < ActiveRecord::Base
  belongs_to :user
  belongs_to :friend, class_name: 'User'

  validates_associated :user, :friend
end
