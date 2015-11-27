require 'oauth2'

namespace :cron do
  desc 'TODO'
  task crawler: :environment do |task, args|
    set_token

    oldest_location = get_locations({ active: true })

    UserHistory.where(end_at: nil).where.not(id: oldest_location).update_all(end_at: Time.now) unless oldest_location.empty?
  end

  task verify_locations: :environment do |task, args|
    set_token

    arel = UserHistory.arel_table
    since = UserHistory.select(:begin_at).order(:begin_at).where(arel[:verified].eq(nil).or(arel[:verified].eq(false))).first

    get_locations({ since: since.begin_at.strftime('%FT%T%:z') }) if since
  end

  task seed: :environment do |task, args|
    set_token
    get_seeding
  end

  task users: :environment do |task, args|
    set_token
    get_users
    get_user_info_shorts
  end

  task projects: :environment do |task, args|
    set_token
    get_projects
  end

  private

  def set_token
    uid = Rails.application.secrets.api_born2code_uid
    secret = Rails.application.secrets.api_born2code_secret
    client = OAuth2::Client.new(uid, secret, site: 'https://api.intra.42.fr', ssl: { verify: false })
    @client_credentials = client.client_credentials
    @token = @client_credentials.get_token
  end

  def get_response(path, params = {})
    @token = @client_credentials.get_token if @token.expired?
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

  def get_projects
    response = get_response_full('/v2/cursus/42/projects')
    projects = []
    updated = 0

    response[:data].each do |data|
      projects << Project.new(id: data['id'], name: data['name'], slug: data['slug'])

      puts '== ' + data['name'].ljust(47, '=')
      get_user_projects(data['id'], data['slug'])
    end

    projects_exists = Project.select(:id, :name, :slug).where(id: projects.map(&:id))

    (projects & projects_exists).zip(projects_exists).each do |data, project|
      project.assign_attributes(data.serializable_hash(only: [:name, :slug]))

      if project.changed?
        project.save
        updated += 1
      end
    end

    puts '=' * 50
    puts 'Update projects: ' + updated.to_s + ' / ' + projects_exists.length.to_s
    Project.import (projects - projects_exists)
    puts 'Adds projects:   ' + (projects.length - projects_exists.length).to_s
  end

  def get_user_projects(project_id, project_slug)
    response = get_response_full('/v2/projects/' + project_slug + '/projects_users')
    user_projects = []
    updated = 0

    response[:data].each do |data|
      user_projects << UserProject.new(id: data['id'], user_id: data['user']['id'], project_id: project_id,
                                   occurrence: data['occurrence'], final_mark: data['final_mark'])
    end

    user_projects_exists = UserProject.select(:id, :final_mark).where(id: user_projects.map(&:id))

    (user_projects & user_projects_exists).zip(user_projects_exists).each do |data, user_project|
      user_project.assign_attributes(data.serializable_hash(only: [:final_mark]))

      if user_project.changed?
        user_project.save
        updated += 1
      end
    end

    puts 'Update user projects: ' + updated.to_s + ' / ' + user_projects_exists.length.to_s
    UserProject.import (user_projects - user_projects_exists)
    puts 'Adds user projects:   ' + (user_projects.length - user_projects_exists.length).to_s
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

  def get_seeding(params = {})
    puts '== ' + (params[:page] || 1).to_s.ljust(47, '=')
    response = get_response('/v2/locations', params)
    adds_locations(response[:data])

    if response[:pagination]['next']
      params[:page] = Rack::Utils.parse_nested_query(URI.parse(response[:pagination]['next']).query)['page']
      max_page = Rack::Utils.parse_nested_query(URI.parse(response[:pagination]['last']).query)['page']
      puts '== ' + (params[:page] + ' / ' + max_page + ' ').ljust(47, '=')
      get_seeding(params)
    end
  end

  def get_locations(params = {})
    response = get_response_full('/v2/locations', params)
    adds_locations(response[:data]).map(&:id)
  end

  def adds_locations(data)
    stories = []
    updated = 0

    data.each do |data|
      stories << UserHistory.new(id: data['id'], user_id: data['user']['id'], begin_at: data['begin_at'],
                                 host: data['host'], end_at: data['end_at'], verified: data['end_at'] != nil)
    end

    stories_exists = UserHistory.select(:id, :end_at, :verified).where(id: stories.map(&:id))

    (stories & stories_exists).zip(stories_exists).each do |data, history|
      history.assign_attributes(data.serializable_hash(only: [:end_at, :verified]))

      if history.changed?
        history.save
        updated += 1
      end
    end

    puts 'Update user history: ' + updated.to_s + ' / ' + stories_exists.length.to_s
    UserHistory.import (stories - stories_exists)
    puts 'Adds users history:   ' + (stories.length - stories_exists.length).to_s

    stories
  end
end
