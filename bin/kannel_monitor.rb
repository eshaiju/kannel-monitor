#!/usr/bin/env ruby

require_relative '../lib/kannel_monitor/kannel_monitor'

kannel_monitor = KannelMonitor::Monitor.new(ARGV[0])
