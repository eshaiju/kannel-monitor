# KannelMonitor

This is ruby gem for monitoring kannle smsc status. This gem will check

 1 kannel status
 2 kannel sms queue
 3 smsc status
 4 smsc queue



## Installation

Add this line to your application's Gemfile:

    gem 'kannel_monitor'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install kannel_monitor

## Usage

    To run this


    $ kannel_monitor ' path to kannel  /kannel_monitor.yml'


Format of kannel_monitor.yml


kannel_settings:
   host: xxxxxxxxxx
   port: xxxxxxx
   username: admin
   password: xxxxxxx
   smsc_to_be_skipped:
    - smsc1
    - smsc2
   kannel_name: 'TEST-KANNEL'
email_settings:
   to: 'example@gmail.com'
   from: 'notification@kannle.in'



## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
