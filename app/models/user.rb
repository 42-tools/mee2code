class User < ActiveRecord::Base
  has_one :user_info_short, dependent: :destroy
  has_many :user_histories, dependent: :destroy

  devise :database_authenticatable, :trackable, :omniauthable,
                                    omniauth_providers: [:born2code]

  def self.from_omniauth(auth)
    UserInfoShort.find_or_create_by(user_id: auth.uid) do |user|
      user.login = auth.info.email
      user.display_name = auth.info.display_name
    end

    User.find_or_create_by(id: auth.uid) do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
    end
  end
end
