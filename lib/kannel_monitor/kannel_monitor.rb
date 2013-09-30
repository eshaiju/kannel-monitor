require 'nokogiri'
require_relative './send_mail'
require_relative './configuration'

module KannelMonitor
  ERROR_COULD_NOT_CONNECT = "Could not connect to Kannel status URL"
  ERROR_XML_PARSING = 'Could not parse Kannel status XML.'
  ERROR_SMSC_QUEUE = 'SMS are getting queued on SMSC :: '
  class Monitor
  	include Mailer
    include Configuration
	  def initialize(configuration_file = {})
      load_settings(configuration_file)	    
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
      @logger.info('Kannel status :: '+kannel_status)
      @kannel_error_status.each do | key,value|
        if kannel_status == key
        	send_mail(value)
          break
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
          @logger.info(status[0] +' :: '+ smsc_id )
          @smsc_error_status.each do | key,value|
		        if status[0] == key
		        	send_mail(value + smsc_id)
              break
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

kannel_monitor = KannelMonitor::Monitor.new('/home/shaiju/kannel/kannel_monitor.yml')
kannel_monitor.start_monitoring