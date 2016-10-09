require 'oauth2'

namespace :crawler do
  desc 'TODO'
  task locations: :environment do
    ActiveRecord::Base.transaction do
      oldest_location = get_locations(filter: { active: true, campus_id: 1 })

      UserHistory.where(end_at: nil, campus_id: 1).where.not(id: oldest_location).update_all(end_at: Time.current) if oldest_location.present?
    end

    ActiveRecord::Base.transaction do
      oldest_location = get_locations(filter: { active: true, campus_id: 7 })

      UserHistory.where(end_at: nil, campus_id: 7).where.not(id: oldest_location).update_all(end_at: Time.current) if oldest_location.present?
    end
  end

  task verify_locations: :environment do
    since = UserHistory.where(verified: nil).or(UserHistory.where(verified: false)).maximum(:begin_at)

    unless since.nil?
      begin_at = since.strftime('%FT%T%:z')
      current_date = Time.current.strftime('%FT%T%:z')

      get_locations(range: { begin_at: '%s,%s' % [begin_at, current_date] })
    end
  end

  task seed: :environment do
    get_locations
  end

  task users: :environment do
    get_users(campus_id: 1)
    get_users(campus_id: 7)
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

  def initialize_token(opts = {})
    @token = @client_credentials.get_token if @token.nil? || @token.expired? || opts.delete(:force_refresh)
  end

  def initialize_request(method, path, opts = {})
    initialize_token

    uri = URI(path.gsub(' ', '%20'))
    path = uri.path
    opts = Rack::Utils.parse_nested_query(uri.query).merge(opts)
    retry_max = 1
    response = @token.send(method, path, opts)
    headers = response.headers
    limit_remaining = (headers['x-ratelimit-remaining'] || 1).to_i
    limit_max = headers['x-ratelimit-limit'].to_i

    x_page = (headers['x-page'] || 1).to_i
    x_per_page = (headers['x-per-page'] || 1).to_f
    x_total = ((headers['x-total'] || 1).to_f / x_per_page).ceil

    if x_total > 1
      puts '== GET (%d / %d) %s' % [x_page, x_total, path] if ENV['MEET2CODE_DEBUG']
    else
      puts '== GET %s' % [path] if ENV['MEET2CODE_DEBUG']
    end

    puts ('== Limite de l\'API dépassé (%d / %d) ' % [limit_remaining, limit_max]).rjust(50, '=') if limit_remaining < 1

    raise response.error if response.error

    response.define_singleton_method(:parsed, -> { return JSON.parse(self.body) }) if response && !headers['Content-Type'].include?('application/json')

    [response, x_total > 1 && x_page < x_total ? x_page + 1 : nil]
  rescue Faraday::ConnectionFailed => e
    puts '== GET %s' % [path]
    puts '== Faraday::ConnectionFailed ====================='
    puts e.message
  rescue OAuth2::Error => e
    puts '== GET %s' % [path]
    puts '== OAuth2Error ==================================='
    msg = JSON.parse(e.message.split("\n")[1])
    puts '%s: %s' % [msg['error'], msg['message']]

    if retry_max > 0
      initialize_token(force_refresh: true) if msg['message'] == 'The access token expired'
      puts '= Essaye de réenvoyer la requête ================='
      retry_max -= 1
      retry
    end
  rescue => e
    puts '== GET %s' % [path]
    puts '== Exception ====================================='
    puts e.message
  end

  def request(method, path, opts = {})
    initialize_credentials if @client_credentials.nil?
    initialize_request(method, path, opts)
  end

  def get(path, params = {})
    response, next_page = request(:get, path, params: params.merge(per_page: 100))
    return {} if response.nil?

    if block_given?
      yield response.parsed
    else
      data = response.parsed
    end

    while next_page
      response, next_page = request(:get, path, params: params.merge(page: next_page, per_page: 100))
      return data if response.nil?

      if block_given?
        yield response.parsed
      else
        data += response.parsed
      end
    end if params[:page].nil?

    data
  end

  def get_projects(opts = {})
    if opts[:cursus_id].class.name != 'Fixnum'
      raise ArgumentError, 'cursus_id must be a Fixnum. %s given.' % [opts[:cursus_id].inspect]
    end

    response = get('/v2/cursus/%d/projects' % [opts[:cursus_id]])
    projects = []
    updated = 0

    response.each do |data|
      projects << Project.new(id: data['id'], name: data['name'], slug: data['slug'])

      puts '== ' + (data['name'] + ' ').ljust(47, '=')
      get_user_projects(data['project_users_url'], data['id'])
    end

    projects_exists = Project.select(:id, :name, :slug).where(id: projects.map(&:id)).order(:id)

    (projects & projects_exists).sort.zip(projects_exists).each do |data, project|
      if data.id != project.id
        puts 'Les données sont discordantes (new: %s, old: %s)' % [data.id, project.id]
        next
      end

      project.assign_attributes(data.serializable_hash(only: [:name, :slug]))

      next unless project.changed?

      begin
        updated += 1 if project.save!
      rescue ActiveRecord::RecordInvalid
        puts '== ActiveRecord::RecordInvalid ==================='
        puts project.erros.messages
      end
    end

    puts '=' * 50
    puts 'Update projects: %d / %d' % [updated, projects_exists.length]
    Project.import(projects - projects_exists)
    puts 'Adds projects:   %d' % [projects.length - projects_exists.length]
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
      if data.id != user_project.id
        puts 'Les données sont discordantes (new: %s, old: %s)' % [data.id, user_project.id]
        next
      end

      user_project.assign_attributes(data.serializable_hash(only: [:final_mark]))

      next unless user_project.changed?

      begin
        updated += 1 if user_project.save!
      rescue ActiveRecord::RecordInvalid
        puts '== ActiveRecord::RecordInvalid ==================='
        puts user_project.erros.messages
      end
    end

    puts 'Update users projects: %d / %d' % [updated, user_projects_exists.length]
    UserProject.import(user_projects - user_projects_exists)
    puts 'Adds users projects:   %d' % [user_projects.length - user_projects_exists.length]
  end

  def get_users(opts = {})
    if opts[:campus_id].class.name != 'Fixnum'
      raise ArgumentError, 'campus_id must be a Fixnum. %s given.' % [opts[:campus_id].inspect]
    end

    get('/v2/campus/%d/users' % [opts[:campus_id]]) do |response|
      ActiveRecord::Base.transaction do
        adds_users(response)
      end
    end
  end

  def adds_users(response)
    users = []
    user_infos = []
    updated = 0

    response.each do |data|
      user = get(data['url'])

      if user.blank?
        puts 'Aucune données sur l\'utilisateur: %s' % [data['login']]
        next
      end

      unless user['email']
        puts '%s à une adresse mail vide' % [user['login']]
        user['email'] = user['login'] + '@42.fr'
      end

      users << User.new(id: user['id'], email: user['email'], password: Devise.friendly_token[0, 20])
      user_infos << UserInfoShort.new(user_id: user['id'], login: user['login'], display_name: user['displayname'],
                                      phone: user['phone'], pool_month: user['pool_month'], pool_year: user['pool_year'],
                                      image_url: user['image_url'], cursus: user['cursus_users'].map { |cursus| cursus['cursus_id'] })
    end

    users_exists = User.select(:id, :email).where(id: users.map(&:id)).order(:id)

    (users & users_exists).sort.zip(users_exists).each do |data, user|
      if data.id != user.id
        puts 'Les données sont discordantes (new: %s, old: %s)' % [data.id, user.id]
        next
      end

      user.assign_attributes(data.serializable_hash(only: [:email]))

      next unless user.changed?

      begin
        updated += 1 if user.save!
      rescue ActiveRecord::RecordInvalid
        puts '== ActiveRecord::RecordInvalid ==================='
        puts user.erros.messages
      rescue ActiveRecord::RecordNotUnique
        puts '== ActiveRecord::RecordNotUnique ================='
        puts 'Adresse mail déjà attribué (data: %s[%s], user: %s[%s])' % [data.email.split('@')[0], data.id, user.email.split('@')[0], user.id]
      end
    end

    puts 'Update users: %d / %d' % [updated, users_exists.length]
    User.import(users - users_exists)
    puts 'Adds users:   %d' % [users.length - users_exists.length]

    updated = 0
    user_infos_exists = UserInfoShort.select(:id, :user_id, :login, :display_name, :phone, :pool_month, :pool_year, :image_url, :cursus).where(user_id: user_infos.map(&:user_id)).order(:user_id)
    user_infos_exists_ids = user_infos_exists.map(&:user_id)

    user_infos.select { |u| user_infos_exists_ids.include?(u.user_id) }.sort { |a, b| a.user_id <=> b.user_id }.zip(user_infos_exists).each do |data, user_info|
      if data.user_id != user_info.user_id
        puts 'Les données sont discordantes (new: %s, old: %s)' % [data.user_id, user_info.user_id]
        next
      end

      user_info.assign_attributes(data.serializable_hash(only: [:login, :display_name, :phone, :pool_month, :pool_year, :image_url, :cursus]))

      next unless user_info.changed?

      begin
        updated += 1 if user_info.save!
      rescue ActiveRecord::RecordInvalid
        puts '== ActiveRecord::RecordInvalid ==================='
        puts user_info.erros.messages
      end
    end

    puts 'Update users info: %d / %d' % [updated, user_infos_exists.length]
    UserInfoShort.import user_infos.reject { |u| user_infos_exists_ids.include?(u.user_id) }
    puts 'Adds users info:   %d' % [user_infos.length - user_infos_exists.length]
  end

  def get_locations(params = {})
    oldest_locations = []

    get('/v2/locations', params) do |response|
      ActiveRecord::Base.transaction do
        oldest_location = adds_locations(response).map(&:id)
        oldest_locations += oldest_location

        yield oldest_location if block_given?
      end
    end

    oldest_locations
  end

  def adds_locations(locations)
    stories = []
    updated = 0

    locations.each do |data|
      if data['user'].nil? || data['user']['id'].nil?
        puts 'Utilisateur non défini (host: %s)' % [data['host']]
        next
      end

      stories << UserHistory.new(id: data['id'], user_id: data['user']['id'], host: data['host'], campus_id: data['campus_id'],
                                 begin_at: data['begin_at'], end_at: data['end_at'], primary: data['primary'], verified: data['end_at'].present?)
    end

    stories_exists = UserHistory.select(:id, :end_at, :verified, :primary, :campus_id).where(id: stories.map(&:id)).order(:id)

    (stories & stories_exists).sort.zip(stories_exists).each do |new_location, old_location|
      if new_location.id != old_location.id
        puts 'Les données sont discordantes (new: %s, old: %s)' % [new_location.id, old_location.id]
        next
      end

      old_location.assign_attributes(new_location.serializable_hash(only: [:end_at, :verified, :primary, :campus_id]))

      next unless old_location.changed?

      begin
        updated += 1 if old_location.save!
      rescue ActiveRecord::RecordInvalid
        puts '== ActiveRecord::RecordInvalid ==================='
        puts old_location.erros.messages
      end
    end

    puts 'Update users histories: %d / %d' % [updated, stories_exists.length]
    UserHistory.import(stories - stories_exists)
    puts 'Adds users histories:   %d' % [stories.length - stories_exists.length]

    stories
  end
end
