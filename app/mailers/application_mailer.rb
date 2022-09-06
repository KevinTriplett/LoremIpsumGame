class ApplicationMailer < ActionMailer::Base
  default from: Rails.configuration.from_email_adr
  default cc: Rails.configuration.admin_email_adrs
  layout "mailer"
end
