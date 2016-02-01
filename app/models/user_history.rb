class UserHistory < ActiveRecord::Base
  belongs_to :user

  scope :logged, -> { where(end_at: nil) }
  scope :range, lambda { |from_time, to_time| where('begin_at < ? AND (end_at >= ? OR end_at = NULL)', to_time, from_time) }
  scope :today, -> { range(Date.current.to_time, Date.current.tomorrow.to_time) }
  scope :yesterday, -> { range(Date.current.yesterday.to_time, Date.current.to_time) }
  scope :cluster, lambda { |index| where('host LIKE ?', %(e#{index}r%)) }

  def self.chart(from_time = Date.current.to_time, to_time = from_time.tomorrow.to_time)
    chart = (0..(from_time.to_date == Date.current ? Time.current.hour : 23)).map { |num| [num, []] }.to_h
    from_time = from_time.to_time
    to_time = to_time.to_time

    self.range(from_time, to_time).each do |history|
      end_at = history.end_at ? history.end_at : Time.current
      min = (history.begin_at < from_time ? 0 : history.begin_at.hour)
      max = (end_at > to_time ? 23 : end_at.hour)

      (min..max).each { |i| chart[i] << history.user_id }
    end

    chart.map { |k, v| v.uniq.count }
  end
end
