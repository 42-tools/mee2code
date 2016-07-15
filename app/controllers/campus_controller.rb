class CampusController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :authenticate_user!, unless: :bypass_ip?
  before_action :set_campus!, only: [:clusters]

  def clusters
    render partial: 'clusters', locals: { clusters: @campus.clusters }
  end

  def clusters_users
    user_histories = UserHistory.logged.includes(:user_info_short)
                                .group_by { |history| history.host.gsub(%r(e(\d+)r\d+p\d+), '\1') }
    render partial: 'clusters_users', locals: { user_histories: user_histories }
  end

  def set_campus!
    @campus_id = params.require(:campus_id).to_sym
    raise 'campus_id don\'t exist' unless [:'1'].include?(@campus_id)

    @campus = Rails.application.config.meet2code.campus[@campus_id]
  end
end
