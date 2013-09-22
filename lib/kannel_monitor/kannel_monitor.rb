require "logger"
require 'yaml'
require 'nokogiri'
require 'open-uri'

module KannelMonitor

  ERROR_COULD_NOT_CONNECT = 'Could not connect to Kannel status URL.'
  ERROR_XML_PARSING = 'Could not parse Kannel status XML.'
  ERROR_KANNEL_SUSPENDED = 'kannel is in suspended state'
  ERROR_KANNEL_ISOLATED = 'kannel is in isolated state'
  ERROR_KANNEL_FULL = 'Kannel maximum-queue-length is achieved'
  ERROR_KANNEL_SHUTDOWN = 'Kannel is stutdown state'
  ERROR_SMSC_OFFLINE = 'SMSC is re-connecting: '
  ERROR_SMSC_DEAD = 'SMSC is dead: '

  class Monitor
	  def initialize(options = {})
	  	@settings = YAML.load_file("../../config/kannel_monitor.yml") 
	  	@logger = Logger.new(STDOUT)
	  end

	  def fetch_kannel_status
	  	begin
		  	url = @settings["url"]
		  	@doc = Nokogiri::HTML(open(url))
		  	@logger.info('Fetching Kannel status from ' + url)
		  rescue Exception => e
		  	@logger.info(ERROR_COULD_NOT_CONNECT)
	  	end

	  	if @doc
        kannel_status = @doc.css('status').text.split(",").first
        if kannel_status =
	  		@logger.info('SMSC Status')
	  		smscs = @doc.css('smsc')
	  		smscs.each do |smsc|
	  		  p smsc_id = smsc.css('id').text
	  		  status = smsc.css('status').text.split(' ')
			    p status[0]

			    if status[0] == 're-connecting'
			    	p text = ERROR_SMSC_OFFLINE + smsc_id
			    	p "sending mail......."
			    elsif status[0] == 'dead'
			    	p text = ERROR_SMSC_DEAD + smsc_id
			    	p "sending mail.........."
			    end
	  		end
	  	end
	  end
	end 
end

kannel_monitor = KannelMonitor::Monitor.new()
kannel_monitor.fetch_kannel_status