require 'oauth2'

namespace :cron do
  desc 'TODO'
  task crawler: :environment do |task, args|
    # ActiveRecord::Base.logger = Logger.new(STDOUT)
    set_token
    crawler
  end

  private

  def set_token
    uid = Rails.application.secrets.api_born2code_uid
    secret = Rails.application.secrets.api_born2code_secret
    client = OAuth2::Client.new(uid, secret, site: 'https://api.intra.42.fr', ssl: { verify: false })
    # client.connection.response :logger
    @token = client.client_credentials.get_token
  end

  def get_response(path, params = {})
    # puts path
    response = @token.get(path, params: params)
    pagination = response.headers['link'].split(', ').map do |p|
      link, params = p.split('; ')
      rel = Rack::Utils.parse_nested_query(params.gsub('"', ''))['rel']
      [rel, link[1..-2]]
    end.to_h if response.headers['link']

    { pagination: pagination || {}, data: response.parsed }
  end

  def get_response_full(path, params = {})
    response = get_response(path, params)
    data = response[:data]
    data += get_response_full(response[:pagination]['next'])[:data] if response[:pagination]['next']

    { data: data }
  end

  def crawler
    since = UserHistory.where(end_at: nil).order(begin_at: :asc).first
    since = UserHistory.new(begin_at: Time.now) unless since
    response = get_response_full('/v2/locations', { since: (since.begin_at).strftime('%FT%T%:z') })
    users = []
    user_info_shorts = []
    stories = []
    updated, errors = 0, 0

    # puts JSON.pretty_generate(response[:data])

    response[:data].each do |data|
      user = User.find_or_initialize_by(id: data['user']['id']) do |user|
        user.email = data['user']['login'] + '@student.42.fr'
        user.password = Devise.friendly_token[0, 20]
      end

      if user.new_record? && !users.include?(user)
        users << user
        user_info_shorts << UserInfoShort.new(login: data['user']['login'])
      end

      history = UserHistory.find_or_initialize_by(id: data['id']) do |history|
        history.user_id = data['user']['id']
        history.begin_at = data['begin_at']
        history.host = data['host']
      end
      history.end_at = data['end_at']
      # puts Time.parse(data['begin_at']).strftime('%FT%T%:z') + ' - ' + (data['end_at'] ? Time.parse(data['end_at']).strftime('%FT%T%:z') : 'nil')

      if history.new_record?
        stories << history
      else
        if history.save
          updated += 1
        else
          errors += 1
        end
      end
    end

    # puts since.begin_at.strftime('%FT%T%:z') + ' - ' + (since.end_at ? since.end_at.strftime('%FT%T%:z') : 'nil')

    puts 'Update user history: ' + updated.to_s + ' (' + errors.to_s + ')'
    insert = User.import users
    puts 'Add users:           ' + insert.num_inserts.to_s + ' (' + (users.count - insert.num_inserts).to_s + ')'
    insert = UserInfoShort.import user_info_shorts
    puts 'Add users info:      ' + insert.num_inserts.to_s + ' (' + (user_info_shorts.count - insert.num_inserts).to_s + ')'
    insert = UserHistory.import stories
    puts 'Add users history:   ' + insert.num_inserts.to_s + ' (' + (stories.count - insert.num_inserts).to_s + ')'
  end
end
