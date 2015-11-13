class UsersController < ApplicationController
  # GET /resource/histories
  def histories
    @histories = current_user.user_histories
  end
end
