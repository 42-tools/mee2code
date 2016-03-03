require 'oauth2'

namespace :crawler do
  desc 'TODO'
  task locations: :environment do |task, args|
    set_token

    oldest_location = get_locations({ filter: 'active:true' })

    UserHistory.where(end_at: nil).where.not(id: oldest_location).update_all(end_at: Time.now) unless oldest_location.empty?
  end

  task verify_locations: :environment do |task, args|
    set_token

    arel = UserHistory.arel_table
    since = UserHistory.select(:begin_at).order(:begin_at).where(arel[:verified].eq(nil).or(arel[:verified].eq(false))).first

    get_locations({ range: 'begin_at:' + since.begin_at.strftime('%FT%T%:z') + ',' + Time.current.strftime('%FT%T%:z') }) if since
  end

  task seed: :environment do |task, args|
    set_token

    puts '== 1 '.ljust(47, '=')

    params = get_seeding

    while params[:next] do
      puts '== ' + (params[:next] + ' / ' + params[:max] + ' ').ljust(47, '=')
      params = get_seeding({ page: params[:next] })
    end
  end

  task users: :environment do |task, args|
    set_token
    get_users
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
    @token = @client_credentials.get_token if @token.nil? || @token.expired?

    begin
      response = @token.get(path, params: params)
    rescue OAuth2::Error
      puts '== OAuth2Error ==================================='
      @token = @client_credentials.get_token
      response = @token.get(path, params: params)
    end

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

      puts '== ' + (data['name'] + ' ').ljust(47, '=')
      get_user_projects(data['project_users_url'], data['id'])
    end

    projects_exists = Project.select(:id, :name, :slug).where(id: projects.map(&:id)).order(:id)

    (projects & projects_exists).sort.zip(projects_exists).each do |data, project|
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

  def get_user_projects(project_users_url, project_id)
    response = get_response_full(project_users_url)
    user_projects = []
    updated = 0

    response[:data].each do |data|
      user_projects << UserProject.new(id: data['id'], user_id: data['user']['id'], project_id: project_id,
                                   occurrence: data['occurrence'], final_mark: data['final_mark'])
    end

    user_projects_exists = UserProject.select(:id, :final_mark).where(id: user_projects.map(&:id)).order(:id)

    (user_projects & user_projects_exists).sort.zip(user_projects_exists).each do |data, user_project|
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
    user_infos = []
    updated = 0

    response[:data].each do |data|
      user = get_response(data['url'])[:data]
      puts user['login'] + ' à une adresse mail vide' unless user['email']
      user['email'] = user['login'] + '@42.fr' unless user['email']
      users << User.new(id: user['id'], email: user['email'], password: Devise.friendly_token[0, 20])
      user_infos << UserInfoShort.new(user_id: user['id'], login: user['login'], display_name: user['displayname'])
    end

    users_exists = User.select(:id, :email).where(id: users.map(&:id)).order(:id)

    (users & users_exists).sort.zip(users_exists).each do |data, user|
      user.assign_attributes(data.serializable_hash(only: [:email]))

      if user.changed?
        begin
          user.save
          updated += 1
        rescue ActiveRecord::RecordNotUnique
          puts 'Adresse mail déjà attribué (data: ' + data.email.split('@')[0] + '[' + data.id.to_s + '], user: ' + user.email.split('@')[0] + '[' + user.id.to_s + '])'
        end
      end
    end

    puts 'Update users: ' + updated.to_s + ' / ' + users_exists.length.to_s
    User.import (users - users_exists)
    puts 'Adds users:   ' + (users.length - users_exists.length).to_s

    updated = 0
    user_infos_exists = UserInfoShort.select(:id, :user_id, :login, :display_name).where(user_id: user_infos.map(&:user_id)).order(:user_id)
    user_infos_exists_ids = user_infos_exists.map(&:user_id)

    user_infos.select { |u| user_infos_exists_ids.include?(u.user_id) }.sort { |a, b| a.user_id <=> b.user_id }.zip(user_infos_exists).each do |data, user_info|
      user_info.assign_attributes(data.serializable_hash(only: [:login, :display_name]))

      if user_info.changed?
        user_info.save
        updated += 1
      end
    end

    puts 'Update users info: ' + updated.to_s + ' / ' + user_infos_exists.length.to_s
    UserInfoShort.import user_infos.reject { |u| user_infos_exists_ids.include?(u.user_id) }
    puts 'Adds users info:   ' + (user_infos.length - user_infos_exists.length).to_s
  end

  def get_seeding(params = {})
    response = get_response('/v2/locations', params)
    adds_locations(response[:data])

    if response[:pagination]['next']
      next_page = Rack::Utils.parse_nested_query(URI.parse(response[:pagination]['next']).query)['page']
      max_page = Rack::Utils.parse_nested_query(URI.parse(response[:pagination]['last']).query)['page']
    end

    { next: next_page || false, max: max_page || false }
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

    stories_exists = UserHistory.select(:id, :end_at, :verified).where(id: stories.map(&:id)).order(:id)

    (stories & stories_exists).sort.zip(stories_exists).each do |data, history|
      history.assign_attributes(data.serializable_hash(only: [:end_at, :verified]))

      if history.changed?
        history.save
        updated += 1
      end
    end

    puts 'Update user histories: ' + updated.to_s + ' / ' + stories_exists.length.to_s
    UserHistory.import (stories - stories_exists)
    puts 'Adds user histories:   ' + (stories.length - stories_exists.length).to_s

    stories
  end
end
