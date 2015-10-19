class User < ActiveRecord::Base
  # :registerable, :recoverable, :rememberable, :validatable
  # :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :trackable, :omniauthable,
                                    omniauth_providers: [:born2code]

  def self.from_omniauth(auth)
    User.find_or_create_by(email: auth.info.email) do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
    end
  end
end
