class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :authentication

  def bypass_ip
    whitelist = ['127.0.0.1/32', '62.210.32.0/24', '62.210.33.0/24', '62.210.34.0/24'].map { |v| IPAddr.new(v) }

    if whitelist.map { |v| v === IPAddr.new(request.remote_ip) }.include?(true)
      return true
    end

    return false
  end

  private

  def authentication
    unless bypass_ip
      authenticate_user!
    end
  end
end
