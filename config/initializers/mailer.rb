Rails.application.config.action_mailer.logger = nil
Rails.application.config.action_mailer.delivery_method = :smtp
Rails.application.config.action_mailer.smtp_settings = {
  enable_starttls_auto: true, authentication: 'plain',
  address: 'smtp.mandrillapp.com', port: 587,
  user_name: Rails.application.secrets.mailer_username,
  password: Rails.application.secrets.mailer_password,
  domain: '42.tools'
}
