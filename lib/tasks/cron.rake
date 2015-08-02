require 'net/http'
require 'cgi'

namespace :cron do
  desc 'TODO'
  task crawler: :environment do |task, args|
    created_at = Time.now

    puts '========================================'
    crawler(created_at, 1, '93f2e1538dfca69539e4d1765b6b93215b5de633')
    puts '+--------------------------------------+'
    crawler(created_at, 4, '99ab41eaf7e8ebb3c475ea3eee70119059fbd557')
    puts '+--------------------------------------+'

    puts 'Updated: ' + UserHistory.where(date_end: nil).where('updated_at < ?', created_at - 1.minutes).update_all(date_end: created_at).to_s
    puts 'Destroy: ' + UserHistory.where('updated_at < ?', Time.now - 1.months).destroy_all.count.to_s
    puts '========================================'
  end

  def crawler(created_at, cursus, token)
    uri = URI.parse("https://api.intrav2.42.fr/cursus/#{cursus}/locations?token=#{token}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    data = http.get(uri.request_uri)
    users = JSON.parse(data.body)
    added, updated = 0, 0

    users.each do |user|
      history = UserHistory.logged.find_by(login: user['login'], location: user['location'])

      if history.nil?
        added = added.next
        UserHistory.create(login: user['login'], location: user['location'], date_begin: created_at)
      else
        updated = updated.next
        history.touch
      end
    end

    puts 'Added: ' + added.to_s
    puts 'Updated: ' + updated.to_s
  end
end
