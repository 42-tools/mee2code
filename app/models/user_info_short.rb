class UserInfoShort < ActiveRecord::Base
  belongs_to :user
  serialize :cursus, Array

  def cursus_piscine?
    cursus.select { |v| v.in?([4, 6, 7]) }.reduce(false, :|) && !cursus.include?(1)
  end

  def cursus_born2code?
    cursus.include?(1)
  end

  def cursus_other?
    !piscine? && !born2code?
  end
end
