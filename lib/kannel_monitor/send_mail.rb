require 'rubygems'
require 'sendmail'
require 'pony'

module KannelMonitor
  class Mailer
    def send_mail(text)
     Pony.mail(
      :from => 'notification@kannel.org', 
      :to => 'shaiju@mobme.in',
      :via => :sendmail, 
      :subject => "#{text}",
      :body => "#{text}")
    end
  end
end


#[CRITICAL] :: FastAlerts SMPP CLIENT :: NOT RESPONDING on PORT 80

#Alert: Not Able to Connect to FA KANNEL on 67.207.134.250 port 80 as on Thu Sep 26 09:03:27 UTC 2013
