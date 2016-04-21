class UsersController < ApplicationController
  before_action :set_friend, only: [:friend_create, :friend_destroy]

  def histories
    @histories = current_user.user_histories.order(begin_at: :desc).group_by { |u| u.begin_at.beginning_of_week }
  end

  def friends
    @friends = current_user.friends
  end

  def friend_create
    unless @friend
      current_user.user_friends.create!(friend_id: params[:friend_id].to_i)
      render status: :created, nothing: true
    else
      render status: :ok, nothing: true
    end
  end

  def friend_destroy
    if @friend
      @friend.destroy!
      render status: :ok, nothing: true
    else
      render status: :unprocessable_entity, nothing: true
    end
  end

  private

  def set_friend
    @friend = current_user.user_friends.find_by(friend_id: params[:friend_id].to_i)
  end
end
