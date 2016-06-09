class Users::SessionsController < Devise::SessionsController
  layout 'devise'

  def new
    return redirect_to root_url if bypass_ip?
    super
  end
end
