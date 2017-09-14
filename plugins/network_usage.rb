#! /usr/bin/env ruby
#  encoding: UTF-8
#
#   networkory-metrics
#
# DESCRIPTION:
#   This is a program for monitor the network usage of the network which
#   includes the traffic rate, peak rate and cumulative data transfered over
#   particular time period
#
# OUTPUT:
#   metric data
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   package: iftop
#
# USAGE:
#
# NOTES:
#
# LICENSE:
#   Copyright 2012 Sonian, Inc <chefs@sonian.net>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugin/metric/cli'

class NetworkGraphite < Sensu::Plugin::Metric::CLI::Graphite

	option :scheme,
         description: 'Metric naming scheme, text to prepend to metric',
         short: '-s SCHEME',
         long: '--scheme SCHEME',
         default: ""

	option :interface,
         description: 'Interface name',
         short: '-i INTERFACE',
         long: '--interface INTERFACE',
         default: ""

	option :interval,
         description: 'The interval for rate calculation, 0 -> 2s 1 -> 10s 2 -> 40s',
         short: '-I INTERVAL',
         long: '--interval INTERVAL',
         integer: true,
         default: 0


def run
#result = `iftop -s 20 -i wlan0 -t| grep rate`
      if(config[:interval].to_i.between?(0,3))
         interface = config[:interface]
         interface_status = `cat /sys/class/net/#{interface}/operstate`
      	 if interface_status.delete!("\n") == "up"
	    network = metrics_hash
	    network.each do |k, v|
            print "#{k}",": ", "#{v}", "\n"
            end
            ok
         else
            print "WARNIHNG: #{interface} is down or not installed!"
            warning
         end
      else
        print 'WARNING: Please input a valid interval!'
        warning
      end
end

def metrics_hash
      interval = config[:interval].to_i
      network = {}
      networkinfo_output.each_line do |line|
      network['Send_rate'] = line.split(/\s+/)[3+interval] if line.match(/Total send rate/)
      network['Receive_rate'] = line.split(/\s+/)[3+interval] if line.match(/Total receive rate/)
      network['Send_receive_rate'] = line.split(/\s+/)[5+interval] if line.match(/Total send and receive rate/)
      network['Peak_rate'] = line.split(/\s+/)[3+interval] if line.match(/Peak rate \(sent\/received\/total\)/)
      #Cumiulative data transfered through the interface over last interval
      network['Cumulative'] = line.split(/\s+/)[2+interval] if line.match(/Cumulative \(sent\/received\/total\)/)
      end

      #interface = config[:interface]
      #return the link speed from kernel: /sys/class/net/#{interface}/speed.
      #This value is only valid when the interface implement the ethtool get_settings method (mostly Ethernet ).
      link_speed = `cat /sys/class/net/#{config[:interface]}/speed`
      if $?.success? == false or link_speed.to_i == 4294967295
        network['Link_speed'] = "UNKNOWN"
      else
        network['Link_speed'] = "#{link_speed}Mb/s".delete!("\n")
      end
    network
end

def networkinfo_output

# An example of last 6 lines of the output of running 'iftop -s 20 -i wlan0 -t'

      #Total send rate:                                     2.54Kb     1.47Kb     1.68Kb
      #Total receive rate:                                  1.50Kb     1.23Kb     2.58Kb
      #Total send and receive rate:                         4.04Kb     2.71Kb     4.26Kb
      #--------------------------------------------------------------------------------------------
      #Peak rate (sent/received/total):                     4.97Kb     9.95Kb     14.9Kb
      #Cumulative (sent/received/total):                    3.78KB     5.79KB     9.58KB
      interface = config[:interface]
      
      # Note: to use iftop without tty related 
      # issue, two lines following must be added to /etc/sudoers
      #
      #    sensu   ALL=(ALL)      NOPASSWD: /usr/sbin/iftop
      #    Defaults:sensu        !requiretty
      result =  `sudo iftop -s 40 -i #{interface} -t -L -6`
end
end
