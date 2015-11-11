require 'oauth2'

namespace :cron do
  desc 'TODO'
  task crawler: :environment do |task, args|
    set_token

    oldest_location = get_locations({ active: true })

    UserHistory.where('begin_at < ?', oldest_location.begin_at).update_all(end_at: Time.now) if oldest_location
  end

  task verify_locations: :environment do |task, args|
    set_token

    since = UserHistory.select(:begin_at).order(begin_at: :asc).find_by(verified: false)

    get_locations({ since: since.begin_at.strftime('%FT%T%:z') }) if since
  end

  task seed: :environment do |task, args|
    set_token
    get_locations
  end

  task users: :environment do |task, args|
    set_token
    get_users
    get_user_info_shorts
  end

  private

  def set_token
    uid = Rails.application.secrets.api_born2code_uid
    secret = Rails.application.secrets.api_born2code_secret
    client = OAuth2::Client.new(uid, secret, site: 'https://api.intra.42.fr', ssl: { verify: false })
    @token = client.client_credentials.get_token
  end

  def get_response(path, params = {})
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

  def get_users
    response = get_response_full('/v2/cursus/42/users')
    users = []
    user_info_shorts = []

    response[:data].each do |data|
      user = User.find_or_initialize_by(id: data['id']) do |user|
        user.email = data['login'] + '@student.42.fr'
        user.password = Devise.friendly_token[0, 20]
      end

      users << user if user.new_record?

      user_info_short = UserInfoShort.find_or_initialize_by(user_id: data['id']) do |user_info_short|
        user_info_short.login = data['login']
      end

      user_info_shorts << user_info_short if user_info_short.new_record?
    end

    insert = User.import users
    puts 'Add users:           ' + insert.num_inserts.to_s + ' (' + (users.count - insert.num_inserts).to_s + ')'
    insert = UserInfoShort.import user_info_shorts
    puts 'Add users info:      ' + insert.num_inserts.to_s + ' (' + (user_info_shorts.count - insert.num_inserts).to_s + ')'
  end

  def get_user_info_shorts
    UserInfoShort.where(display_name: nil).each do |user_info_short|
      response = get_response('/v2/users/' + user_info_short.user_id.to_s)
      data = response[:data]
      user_info_short.user.update(email: data['email']) if data['email']
      user_info_short.update(login: data['login'], display_name: data['displayname'])
    end
  end

  def get_locations(params = {})
    response = get_response_full('/v2/locations', params)
    stories = []
    updated, errors = 0, 0

    response[:data].each do |data|
      history = UserHistory.find_or_initialize_by(id: data['id']) do |history|
        history.user_id = data['user']['id']
        history.begin_at = data['begin_at']
        history.host = data['host']
      end
      history.end_at = data['end_at']
      history.verified = data['end_at'] != nil

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

    puts 'Update user history: ' + updated.to_s + ' (' + errors.to_s + ')'
    insert = UserHistory.import stories
    puts 'Add users history:   ' + insert.num_inserts.to_s + ' (' + (stories.count - insert.num_inserts).to_s + ')'

    stories.sort { |x, y| x.begin_at <=> y.begin_at }.first
  end
end
