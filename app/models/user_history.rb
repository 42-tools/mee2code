class UserHistory < ActiveRecord::Base
  belongs_to :user, required: false
  has_one :user_info_short, through: :user

  scope :logged, -> { where('host LIKE ?', 'e%r%p%').where(end_at: nil) }
  scope :range, -> (from_time, to_time) { where('begin_at < ?', to_time).where('end_at >= ? OR end_at = NULL', from_time) }
  scope :today, -> { range(Date.current.to_time, Date.current.tomorrow.to_time) }
  scope :yesterday, -> { range(Date.current.yesterday.to_time, Date.current.to_time) }
  scope :cluster, -> (index) { where('host LIKE ?', %(e#{index}r%)) }

  def self.chart(from_time = Date.current, to_time = from_time.tomorrow)
    chart = (0..(from_time == Date.current ? Time.current.hour : 23)).map { |num| [num, 0] }.to_h
    from_time = from_time.to_time
    to_time = to_time.to_time

    if connection.adapter_name == 'SQLite'
      histories = self.range(from_time, to_time).group('strftime("%H", begin_at)', :id).count
    else
      histories = self.range(from_time, to_time).group('EXTRACT(HOUR FROM begin_at)', :id).count
    end

    result = chart.merge(histories.group_by { |(hour, _user_id), _count| hour }.sort_by { |hour| hour }
                                  .map { |hour, data| [hour.to_i, data.count] }.to_h)

    result.map { |hour, data| [(from_time + hour.hour).to_i * 1000, data] }
  end
end
