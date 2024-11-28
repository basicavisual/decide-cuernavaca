if Rails.application.secrets.dig(:omniauth, :esignet).present?

  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :openid_connect,
             setup: lambda { |env|
               request = Rack::Request.new(env)
               organization = Decidim::Organization.find_by(host: request.host)
               provider_config = organization.enabled_omniauth_providers[:esignet]
               env["omniauth.strategy"].options = {
                 name: :decidim_esignet,
                 issuer: "https://esignet.collab.mosip.net",
                 scope: [:openid, :email, :profile, :phone],
                 response_type: :code,
                 uid_field: "profile",
                 client_options: {
                   port: 443,
                   scheme: "https",
                   host: "cuernavaca.basicavisual.io",
                   identifier: ENV.fetch("OP_CLIENT_ID", nil),
                   secret: ENV.fetch("OP_SECRET_KEY", nil),
                   redirect_uri: ENV.fetch("OP_REDIRECT_URI", nil),
                   authorization_endpoint: "https://esignet.collab.mosip.net/authorize",
                   token_endpoint: "https://esignet.collab.mosip.net/v1/esignet/oauth/v2/token",
                   userinfo_endpoint: "https://esignet.collab.mosip.net/v1/esignet/oidc/userinfo",
                   jwks_uri: "https://esignet.collab.mosip.net/.well-known/jwks.json"
                 }
               }
             }
  end
end
