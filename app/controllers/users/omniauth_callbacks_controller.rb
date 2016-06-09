class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def born2code
    @user = User.from_omniauth(request.env['omniauth.auth'])

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: 'Born2Code') if is_navigational_format?
    else
      redirect_to new_user_session_url
    end
  end
end
