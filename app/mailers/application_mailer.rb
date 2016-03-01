class ApplicationMailer < ActionMailer::Base
  default from: 'Meet2Code <noreply@42.tools>',
          reply_to: 'Meet2Code <contact@42.tools>'
  layout 'mailer'
end
