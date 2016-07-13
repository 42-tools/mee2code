class UserInfoShort < ActiveRecord::Base
  belongs_to :user
  serialize :cursus, Array

  def piscine?
    cursus.select { |v| v.in?([4, 6, 7]) }.reduce(false, :|) && !cursus.include?(1)
  end
end
