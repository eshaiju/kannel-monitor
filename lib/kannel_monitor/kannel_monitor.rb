require "logger"
require 'yaml'
require 'nokogiri'
require 'open-uri'
require 'active_support/core_ext'
require './send_mail'

module KannelMonitor
  ERROR_COULD_NOT_CONNECT = "Could not connect to Kannel status URL"
  ERROR_XML_PARSING = 'Could not parse Kannel status XML.'
  ERROR_SMSC_QUEUE = 'SMS are getting queued on SMSC :: '
  class Monitor
  	include Mailer
	  def initialize(options = {})
	    @settings = YAML.load_file('../../config/kannel_monitor.yml').symbolize_keys!
	  	@host = @settings[:kannel_settings]['host']
    	@port = @settings[:kannel_settings]['port']
   		@username = @settings[:kannel_settings]['username']
      @password = @settings[:kannel_settings]['password']
      @smsc_to_be_skipped = @settings[:kannel_settings]['smsc_to_be_skipped'] || []
      @queue_alert_limit =  @settings[:kannel_settings]['queue_alert_limit'] || 200
	  	@kannel_name =  @settings[:kannel_settings]['kannel_name'] || ""
	  	@logger = Logger.new(STDOUT)
	  	@kannel_error_status = {'suspended' =>'kannel is in suspended state','isolated' => 'kannel is in isolated state' ,'full' => 'Kannel maximum-queue-length is achieved' ,'shutdown' =>'Kannel is shutdown state'}
      @smsc_error_status = {'re-connecting' => 'SMSC is re-connecting :: ' , 'dead' => 'SMSC is dead ::' }
	  end

	  def start_monitoring
	  	@xml_doc = prepare_xml_doc
	  	if @xml_doc
		  	fetch_kannel_status
		  	fetch_smsc_status
		  	fetch_queued_count
	  	end
	  end	

	  def prepare_xml_doc
	  	begin
        @xml_content_doc = Nokogiri::XML(open("http://#{@host}:#{@port}/status.xml?username=#{@username}&password=#{@password}"))
	  	  @logger.info("Fetching Kannel status from http://#{@host}:#{@port}/status.xml?username=#{@username}&password=#{@password}")
		  rescue 
		  	@logger.info(ERROR_COULD_NOT_CONNECT)
        send_mail(ERROR_COULD_NOT_CONNECT)
	  	end
	  	@xml_content_doc
	  end

	  def fetch_kannel_status
      kannel_status = @xml_doc.css('status').text.split(",").first
      @kannel_error_status.each do | key,value|
        if kannel_status == key
        	@logger.info(value)
        	send_mail(value)
        end
      end
	  end

	  def fetch_smsc_status
	  	@logger.info('SMSC Status')
  		smscs = @xml_doc.css('smsc')
  		smscs.each do |smsc|
  		  smsc_id = smsc.css('id').text
  		  smsc_queue = smsc.css('queued').text
  		  unless @smsc_to_be_skipped.include?(smsc_id) 
	  		  status = smsc.css('status').text.split(' ')
          @smsc_error_status.each do | key,value|
		        if status[0] == key
		        	@logger.info(value + smsc_id )
		        	send_mail(value + smsc_id)
		        end
		      end
			    if smsc_queue.to_i > @queue_alert_limit.to_i
			    	@logger.info(ERROR_SMSC_QUEUE + smsc_id)
            send_mail(ERROR_SMSC_QUEUE + smsc_id)
			    end	
			  end
  		end
	  end

	  def fetch_queued_count
	  	sent_status = @xml_doc.css('sent')
	  	sent_status.each do |status|
	  		queue_size = status.css('queued').text
	  		if queue_size.to_i > @queue_alert_limit.to_i
	  			text = "SMS are getting queued"
          send_mail(text)
	  		end
	  	end	
	  end

	end 
end

kannel_monitor = KannelMonitor::Monitor.new()
kannel_monitor.start_monitoring