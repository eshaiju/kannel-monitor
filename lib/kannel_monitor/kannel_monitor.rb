require "logger"
require 'yaml'
require 'nokogiri'
require 'open-uri'
require 'active_support/core_ext'
require './send_mail'

module KannelMonitor

  ERROR_COULD_NOT_CONNECT = 'Could not connect to Kannel status URL.'
  ERROR_XML_PARSING = 'Could not parse Kannel status XML.'
  ERROR_KANNEL_SUSPENDED = 'kannel is in suspended state'
  ERROR_KANNEL_ISOLATED = 'kannel is in isolated state'
  ERROR_KANNEL_FULL = 'Kannel maximum-queue-length is achieved'
  ERROR_KANNEL_SHUTDOWN = 'Kannel is shutdown state'
  ERROR_SMSC_OFFLINE = 'SMSC is re-connecting: '
  ERROR_SMSC_DEAD = 'SMSC is dead: '

  class Monitor
	  def initialize(options = {})
	    @settings = YAML.load_file('../../config/kannel_monitor.yml').symbolize_keys!
	  	@host = @settings[:kannel_settings]['host']
    	@port = @settings[:kannel_settings]['port']
   		@username = @settings[:kannel_settings]['username']
      @password = @settings[:kannel_settings]['password']
      @smsc_to_be_skipped = @settings[:kannel_settings]['smsc_to_be_skipped']
      @queue_alert_limit =  @settings[:kannel_settings]['queue_alert_limit']
	  	@logger = Logger.new(STDOUT)
      @mail_client = KannelMonitor::Mailer.new()
	  end

	  def start_monitoring
	  	@xml_doc = prepare_xml_doc
	  	if @xml_doc
		  	fetch_kannel_status
		  	fetch_smsc_status
		  	fetch_queued_count
	  	end
	  end	

	  def fetch_queued_count
	  	sent_status = @xml_doc.css('sent')
	  	sent_status.each do |status|
	  		p queue_size = status.css('queued').text
	  		if queue_size.to_i > @queue_alert_limit.to_i
	  			p text = "sms are getting queued"
	  			p "sending mail.........."
          @mail_client.send_mail(text)
	  		end
	  	end	
	  end

	  def fetch_kannel_status
      p kannel_status = @xml_doc.css('status').text.split(",").first
      if kannel_status == 'suspended'
        text = ERROR_KANNEL_SUSPENDED 
        @logger.info(ERROR_KANNEL_SUSPENDED)
        p "sending mail.........."
        @mail_client.send_mail(text)
      elsif kannel_status == 'isolated'
      	text = ERROR_KANNEL_ISOLATED
      	@logger.info(ERROR_KANNEL_ISOLATED)
      	p "sending mail.........."
        @mail_client.send_mail(text)
      elsif kannel_status == 'full'
      	text = ERROR_KANNEL_FULL
      	@logger.info(ERROR_KANNEL_FULL)
      	p "sending mail.........."
        @mail_client.send_mail(text)
      elsif kannel_status == 'shutdown'
      	text = ERROR_KANNEL_SHUTDOWN
        @logger.info(ERROR_KANNEL_SHUTDOWN)
      	p "sending mail.........."
        @mail_client.send_mail(text)
      end
	  end

	  def fetch_smsc_status
	  	@logger.info('SMSC Status')
  		smscs = @xml_doc.css('smsc')
  		smscs.each do |smsc|
  		  p smsc_id = smsc.css('id').text
  		  p smsc_queue = smsc.css('queued').text
  		  unless (@smsc_to_be_skipped.include?(smsc_id) rescue false)
	  		  status = smsc.css('status').text.split(' ')
			    p status[0]
			    if status[0] == 're-connecting'
			    	p text = ERROR_SMSC_OFFLINE + smsc_id
			    	@logger.info(ERROR_SMSC_OFFLINE + smsc_id)
			    	p "sending mail......."
            @mail_client.send_mail(text)
			    elsif status[0] == 'dead'
			    	p text = ERROR_SMSC_DEAD + smsc_id
			    	@logger.info(ERROR_SMSC_DEAD + smsc_id)
			    	p "sending mail.........."
            @mail_client.send_mail(text)
			    end
			    if smsc_queue.to_i > @queue_alert_limit.to_i
			    	p "sms are getting queued"
			    	@logger.info("sms are getting queued" + smsc_id)
			    	p "sending mail.........."
            @mail_client.send_mail(text)
			    end	
			  end
  		end
	  end

	  def prepare_xml_doc
	  	begin
        @xml_content_doc = Nokogiri::XML(open("http://#{@host}:#{@port}/status.xml?username=#{@username}&password=#{@password}"))
	  	  @logger.info("Fetching Kannel status from http://#{@host}:#{@port}/status.xml?username=#{@username}&password=#{@password}")
		  rescue 
		  	@logger.info(ERROR_COULD_NOT_CONNECT)
        @mail_client.send_mail(ERROR_COULD_NOT_CONNECT)
	  	end
	  	@xml_content_doc
	  end

	end 
end

kannel_monitor = KannelMonitor::Monitor.new()
kannel_monitor.start_monitoring