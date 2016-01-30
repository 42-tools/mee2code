class UserHistory < ActiveRecord::Base
  belongs_to :user

  scope :logged, -> { where(end_at: nil) }
  scope :range, lambda { |from_time, to_time| where('begin_at >= ?', from_time).where('begin_at < ?', to_time) }
  scope :today, -> { range(Date.current, Date.current.tomorrow) }
  scope :yesterday, -> { range(Date.current.yesterday, Date.current) }
  scope :cluster, lambda { |index| where('host LIKE ?', %(e#{index}r%)) }

  def self.users_by_hour(from_time = Date.current, to_time = from_time.tomorrow)
    Hash[(0..(from_time.to_date == Date.current ? Time.current.hour : 23)).map { |num| [num, 0] }].merge(
      self.range(from_time.to_date, to_time.to_date).group_by{ |u| u.begin_at.beginning_of_hour }.map { |date, users| [date.hour, users.group_by { |u| u.user_id }.count] }.to_h
    ).values
  end
end
