class ApplicationMailer < ActionMailer::Base
  default from: Rails.configuration.from_email_adr
  layout "mailer"
end
