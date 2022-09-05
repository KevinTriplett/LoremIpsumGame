class ApplicationMailer < ActionMailer::Base
  default from: "noreply@loremipsumgame.com"
  default cc: ["kt@kevintriplett.com", "speaktokai@gmail.com"]
  layout "mailer"
end
