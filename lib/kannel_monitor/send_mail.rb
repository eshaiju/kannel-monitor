require 'rubygems'
require 'net/smtp'

module KannelMonitor
  class Mailer
    def send_mail(text)
      from = 'notification@kannel.org'
      to = 'shaiju@mobme.in'
      message = <<MESSAGE
From: Kannel Notification <#{from}>
To: Name of the recepient <#{to}>
MIME-Version: 1.0
Content-type: text/html
Subject: #{text}
MESSAGE
      Net::SMTP.start('localhost',25) do |smtp|
          smtp.send_message [message, "#{text}"].join("\r\n"),from,to
      end
    end
  end

end

