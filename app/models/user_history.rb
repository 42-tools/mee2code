class UserHistory < ActiveRecord::Base
  belongs_to :user

  scope :logged, -> { where(end_at: nil) }
  scope :cluster, lambda { |index| where('host LIKE ?', %(e#{index}r%)) }
end
