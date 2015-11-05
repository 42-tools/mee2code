class User < ActiveRecord::Base
  has_one :user_info_short
  has_many :user_histories

  # :registerable, :recoverable, :rememberable, :validatable
  # :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :trackable, :omniauthable,
                                    omniauth_providers: [:born2code]

  after_commit :initialize_models, on: [:create]

  def self.from_omniauth(auth)
    User.find_or_create_by(email: auth.info.email) do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
    end
  end

  private

  def initialize_models
    self.create_user_info_short
  end
end
