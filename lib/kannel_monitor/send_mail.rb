require 'rubygems'
require 'sendmail'
require 'pony'

module KannelMonitor
  module Mailer
    def send_mail(text)
     Pony.mail(
      :from => 'notification@kannel.org', 
      :to => 'eshaiju@gmail.com,shaiju@mobme.in',
      :via => :sendmail, 
      :subject => "[CRITICAL]::#{@kannel_name}::#{text}".upcase,
      :body => "Kannel Name : #{@kannel_name} \nHost : #{@host} \nPort : #{@port} \n#{text} as on #{Time.now}")
    end
  end
end
