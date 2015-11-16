class UsersController < ApplicationController
  # GET /resource/histories
  def histories
    @histories = current_user.user_histories.order(begin_at: :desc).group_by{ |u| u.begin_at.beginning_of_week }
  end
end
