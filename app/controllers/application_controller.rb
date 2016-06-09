class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!

  private

  def bypass_ip?
    whitelist = ['127.0.0.1', '::1', '62.210.32.0/24', '62.210.33.0/24', '62.210.34.0/24'].map { |v| IPAddr.new(v) }

    return true if whitelist.map { |v| v === IPAddr.new(request.remote_ip) }.include?(true)

    false
  end
end
