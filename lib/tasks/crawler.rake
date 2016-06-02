require 'oauth2'

namespace :crawler do
  desc 'TODO'
  task locations: :environment do
    oldest_location = get_locations(filter: 'active:true')

    if oldest_location.present?
      UserHistory.where(end_at: nil).where.not(id: oldest_location).update_all(end_at: Time.current)
    end
  end

  task verify_locations: :environment do
    since = UserHistory.select(:begin_at).order(:begin_at).where(verified: nil).or(since.where(verified: false)).first

    if since.present?
      begin_at = since.begin_at.strftime('%FT%T%:z')
      current_data = Time.current.strftime('%FT%T%:z')

      get_locations(range: "begin_at: #{begin_at},#{current_data}")
    end
  end

  task seed: :environment do
    get_locations
  end

  task users: :environment do
    get_users(campus_id: 1)
  end

  task projects: :environment do
    get_projects(cursus_id: 1)
  end

  private

  def initialize_credentials
    uid = Rails.application.secrets.api_born2code_uid
    secret = Rails.application.secrets.api_born2code_secret
    params = { site: 'https://api.intra.42.fr', ssl: { verify: false }, raise_errors: false }
    client = OAuth2::Client.new(uid, secret, params)
    @client_credentials = client.client_credentials
  end

  def initialize_request(method, path, opts = {})
    @token = @client_credentials.get_token if @token.nil? || @token.expired? || opts.delete(:force_refresh)
    raise_errors = opts.delete(:raise_errors) || false

    response = @token.send(method, path, opts)
    headers = response.headers
    limit_remaining = (headers['x-ratelimit-remaining'] || 1).to_i
    limit_max = headers['x-ratelimit-limit'].to_i

    x_page = (headers['x-page'] || 1).to_i
    x_total = (headers['x-total'] || 1).to_f
    x_per_page = (headers['x-per-page'] || 1).to_f

    if x_total == 1
      puts "== GET #{path}"
    else
      puts "== GET (#{x_page} / #{(x_total / x_per_page).round}) #{path}"
    end

    puts "== Limite de l\'API dépassé (#{limit_remaining} / #{limit_max}) ".rjust(50, '=') if limit_remaining < 1

    raise response.error if response.error

    response
  rescue Faraday::ConnectionFailed => e
    puts "== GET #{path}"
    puts '== Faraday::ConnectionFailed ====================='
    puts e.message
  rescue OAuth2::Error => e
    puts "== GET #{path}"
    puts '== OAuth2Error ==================================='
    msg = JSON.parse(e.message.split("\n")[1])
    puts "#{msg['error']}: #{msg['message']}"

    raise e if msg['message'] == 'The access token expired' && raise_errors
  rescue => e
    puts "== GET #{path}"
    puts '== Exception ====================================='
    puts e.message
  end

  def request(method, path, opts = {})
    initialize_credentials if @client_credentials.nil?

    begin
      initialize_request(method, path, opts.merge(raise_errors: true))
    rescue OAuth2::Error
      puts '= Essaye de réenvoyer la requête ================='
      initialize_request(method, path, opts.merge(force_refresh: true))
    end
  end

  def pagination_compute(response)
    pagination = response.headers['link'].split(', ').map do |str|
      link, params = str.split('; ')
      rel = Rack::Utils.parse_nested_query(params.delete('"'))['rel']
      [rel, Rack::Utils.parse_nested_query(URI.parse(link[1..-2]).query)['page'].to_i]
    end.to_h if response.headers['link'].present?

    puts '= Impossible de traiter la pagination ============' if pagination.blank?

    pagination
  end

  def get(path, params = {})
    response = request(:get, path, params: params.merge(per_page: 100))
    return {} if response.nil?

    if params[:page].nil?
      pagination = pagination_compute(response)
      return {} if pagination.blank?
      next_page = pagination['next']
    end

    data = response.parsed

    while next_page
      response = request(:get, path, params: params.merge(page: next_page, per_page: 100))
      return data if response.nil?

      pagination = pagination_compute(response)
      return data if pagination.blank?

      next_page = pagination['next']
      data += response.parsed
    end if params[:page].nil?

    data
  end

  def get_projects(opts = {})
    if opts[:cursus_id].class.name != 'Fixnum'
      raise ArgumentError, "cursus_id must be a Fixnum. #{opts[:cursus_id].inspect} given."
    end

    response = get("/v2/cursus/#{opts[:cursus_id]}/projects")
    projects = []
    updated = 0

    response.each do |data|
      projects << Project.new(id: data['id'], name: data['name'], slug: data['slug'])

      puts '== ' + (data['name'] + ' ').ljust(47, '=')
      get_user_projects(data['project_users_url'], data['id'])
    end

    projects_exists = Project.select(:id, :name, :slug).where(id: projects.map(&:id)).order(:id)

    (projects & projects_exists).sort.zip(projects_exists).each do |data, project|
      project.assign_attributes(data.serializable_hash(only: [:name, :slug]))

      next unless project.changed?

      project.save
      updated += 1
    end

    puts '=' * 50
    puts "Update projects: #{updated} / #{projects_exists.length}"
    Project.import(projects - projects_exists)
    puts "Adds projects:   #{projects.length - projects_exists.length}"
  end

  def get_user_projects(project_users_url, project_id)
    response = get(project_users_url)
    user_projects = []
    updated = 0

    response.each do |data|
      user_projects << UserProject.new(id: data['id'], user_id: data['user']['id'], project_id: project_id,
                                       occurrence: data['occurrence'], final_mark: data['final_mark'])
    end

    user_projects_exists = UserProject.select(:id, :final_mark).where(id: user_projects.map(&:id)).order(:id)

    (user_projects & user_projects_exists).sort.zip(user_projects_exists).each do |data, user_project|
      user_project.assign_attributes(data.serializable_hash(only: [:final_mark]))

      next unless user_project.changed?

      user_project.save
      updated += 1
    end

    puts "Update user projects: #{updated} / #{user_projects_exists.length}"
    UserProject.import(user_projects - user_projects_exists)
    puts "Adds user projects:   #{user_projects.length - user_projects_exists.length}"
  end

  def get_users(opts = {})
    if opts[:campus_id].class.name != 'Fixnum'
      raise ArgumentError, "campus_id must be a Fixnum. #{opts[:campus_id].inspect} given."
    end

    response = get("/v2/campus/#{opts[:campus_id]}/users")
    users = []
    user_infos = []
    updated = 0

    response.each do |data|
      user = get('/v2/users/' + data['login'], page: 1)
      next if user.blank?
      puts user['login'] + ' à une adresse mail vide' unless user['email']
      user['email'] = user['login'] + '@42.fr' unless user['email']
      users << User.new(id: user['id'], email: user['email'], password: Devise.friendly_token[0, 20])
      user_infos << UserInfoShort.new(user_id: user['id'], login: user['login'], display_name: user['displayname'],
                                      phone: user['phone'], pool_month: user['pool_month'], pool_year: user['pool_year'],
                                      image_url: user['image_url'])
    end

    users_exists = User.select(:id, :email).where(id: users.map(&:id)).order(:id)

    (users & users_exists).sort.zip(users_exists).each do |data, user|
      user.assign_attributes(data.serializable_hash(only: [:email]))

      next unless user.changed?

      begin
        user.save
        updated += 1
      rescue ActiveRecord::RecordNotUnique
        puts 'Adresse mail déjà attribué (data: ' + data.email.split('@')[0] + '[' + data.id.to_s + '], user: ' + user.email.split('@')[0] + '[' + user.id.to_s + '])'
      end
    end

    puts "Update users: #{updated} / #{users_exists.length}"
    User.import(users - users_exists)
    puts "Adds users:   #{users.length - users_exists.length}"

    updated = 0
    user_infos_exists = UserInfoShort.select(:id, :user_id, :login, :display_name, :phone, :pool_month, :pool_year, :image_url).where(user_id: user_infos.map(&:user_id)).order(:user_id)
    user_infos_exists_ids = user_infos_exists.map(&:user_id)

    user_infos.select { |u| user_infos_exists_ids.include?(u.user_id) }.sort { |a, b| a.user_id <=> b.user_id }.zip(user_infos_exists).each do |data, user_info|
      user_info.assign_attributes(data.serializable_hash(only: [:login, :display_name, :phone, :pool_month, :pool_year, :image_url]))

      if user_info.changed?
        user_info.save
        updated += 1
      end
    end

    puts "Update users info: #{updated} / #{user_infos_exists.length}"
    UserInfoShort.import user_infos.reject { |u| user_infos_exists_ids.include?(u.user_id) }
    puts "Adds users info:   #{user_infos.length - user_infos_exists.length}"
  end

  def get_locations(params = {})
    response = get('/v2/locations', params)
    adds_locations(response).map(&:id)
  end

  def adds_locations(locations)
    stories = []
    updated = 0

    locations.each do |data|
      next unless data['user']

      stories << UserHistory.new(id: data['id'], user_id: data['user']['id'], host: data['host'],
                                 begin_at: data['begin_at'], end_at: data['end_at'], verified: data['end_at'].present?)
    end

    stories_exists = UserHistory.select(:id, :end_at, :verified).where(id: stories.map(&:id)).order(:id)

    (stories & stories_exists).sort.zip(stories_exists).each do |new_location, old_location|
      old_location.assign_attributes(new_location.serializable_hash(only: [:end_at, :verified]))

      next unless old_location.changed?

      old_location.save
      updated += 1
    end

    puts "Update user histories: #{updated} / #{stories_exists.length}"
    UserHistory.import(stories - stories_exists)
    puts "Adds user histories:   #{stories.length - stories_exists.length}"

    stories
  end
end
