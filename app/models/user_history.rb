class UserHistory < ActiveRecord::Base
  scope :logged, -> { where(date_end: nil) }

  def self.cluster(index)
    where('location LIKE ?', "e#{index}r%").pluck(:location, :login).to_h
  end
end
