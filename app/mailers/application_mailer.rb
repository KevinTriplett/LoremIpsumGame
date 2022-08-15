class ApplicationMailer < ActionMailer::Base
  default from: "noreply@loremipsumgame.com"
  default cc: "kt@kevintriplett.com"
  layout "mailer"
end
