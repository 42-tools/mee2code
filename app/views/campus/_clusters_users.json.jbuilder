user_histories.each do |k, v|
  json.set! k do
    json.array! v do |user_history|
      json.(user_history, :host, :begin_at)
      json.user(user_history.user_info, :login, :display_name, :image_url) unless user_history.user_info.nil?
    end
  end
end
