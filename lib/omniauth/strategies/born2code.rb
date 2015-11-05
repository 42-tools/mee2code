require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Born2code < OmniAuth::Strategies::OAuth2
      option :name, :born2code

      option :client_options, {
        site: 'https://api.intra.42.fr',
        authorize_path: '/oauth/authorize',
        token_path: '/oauth/token'
      }

      uid { raw_info['id'].to_s }

      info do
        {
          email: raw_info['email'],
          login: raw_info['login'],
          name: raw_info['displayname'],
          picture: raw_info['image_url'],
        }
      end

      def raw_info
        @raw_info ||= access_token.get('/v2/me').parsed
      end
    end
  end
end
