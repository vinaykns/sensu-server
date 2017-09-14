#!/usr/bin/env ruby
# http://www.cisco.com/c/en/us/support/docs/ip/simple-network-management-protocol-snmp/8141-calculate-bandwidth-snmp.html
#
require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-plugin/metric/cli'
require 'snmp'
require 'time'
require 'pry'

class SNMPIfStats < Sensu::Plugin::Metric::CLI::Graphite
  option :host,
    short: '-h host',
    boolean: true,
    default: '127.0.0.1',
    required: true

  option :community,
    short: '-C snmp community',
    boolean: true,
    default: 'public'

  option :ishighspeed,
    description: 'default value is false, if the link speed is greater than 1 gigabits/s, please use true',
    short: '-s ishighspeed',
    boolean: true,
    default: false
  
  option :threshold,
    description: 'The threshold of the traffic at which the progrom will exit with critical state',
    short: '-t threshold',
    boolean: true,
    default: 0
  
  option :interval,
    short: '-i interval',
    boolean: true

    
  def run
    critical_state = false
    switchName = getSystemName

    ifTable_first_poll_cols = ["ifDescr", "ifInOctets", "ifOutOctets"]
    ifTable_sec_poll_cols = ["ifDescr", "ifInOctets", "ifOutOctets", "ifOperStatus", config[:ishighspeed] ? "ifHighSpeed":"ifSpeed"]

    octets_start = {}
    SNMP::Manager.open(:host => "#{config[:host]}", :community => "#{config[:community]}") do |manager|
      start_timer = Time.now.to_i
      #Mark the time of starting polling
      #First polling start
      manager.walk(ifTable_first_poll_cols) do |row|
        interfaceName = row[0].value.downcase
        key = [switchName,interfaceName,"ifInSpeed"].join(".")
        octets_start[key] = row[1].value

        key = [switchName,interfaceName,"ifOutSpeed"].join(".")
        octets_start[key] = row[2].value
      end

      #sleep 5 secs
      poll_interval = config[:interval].to_i
      sleep(poll_interval)

      #Second polling start
      speed_metrics = {}

      manager.walk(ifTable_sec_poll_cols) do |row|

        interfaceName = row[0].value.downcase
        
        # Put channel/vlan/interface status
        status_key = [switchName,interfaceName,"ifStatus"].join(".")
        speed_metrics[status_key] = row[3].value

        # SNMP ifHighSpeed is current bandwidth in units of 100000 bits/s, ifSpeed is of 1 bit/s
        bandwidth = (config[:ishighspeed] ? row[4].value.to_f*1000000 : row[4].value.to_f)
        bandwidth_key = [switchName,interfaceName,"bandwidth"].join(".")
        speed_metrics[bandwidth_key] = bandwidth

        # Put channel/vlan/interface inbound speed
        speed_key = [switchName,interfaceName,"ifInSpeed"].join(".")
        utilization_key = [switchName,interfaceName,"ifInUtilization"].join(".")
        ifInSpeed = (row[1].value.to_f - octets_start[speed_key].to_f)*8 / poll_interval
	
	if config[:threshold].to_f > 0 && ifInSpeed > config[:threshold].to_f
           critical_state = true
	end
        #speed_metrics[speed_key] = (ifInSpeed < 0) ? recalculateNegatives(speed_key, ifInSpeed) : ifInSpeed 
        speed_metrics[speed_key] = recalculateNegatives(speed_key, ifInSpeed)  

        speed_metrics[utilization_key] = (ifInSpeed.to_f/ bandwidth.to_f)

        # Put channel/vlan/interface outbound speed
        speed_key = [switchName,interfaceName,"ifOutSpeed"].join(".")
        utilization_key = [switchName,interfaceName,"ifOutUtilization"].join(".")
        ifOutSpeed = (row[2].value.to_f - octets_start[speed_key].to_f)*8 / poll_interval

        #speed_metrics[speed_key] = (ifOutSpeed < 0) ? recalculateNegatives(speed_key, ifOutSpeed) : ifInSpeed 
        speed_metrics[speed_key] = recalculateNegatives(speed_key, ifOutSpeed)  

	if config[:threshold].to_f > 0 && ifOutSpeed.to_f > config[:threshold].to_f
           critical_state = true
        end

        speed_metrics[utilization_key] = (ifOutSpeed.to_f*100/ bandwidth.to_f)
      end

      speed_metrics.each do |key,value|
        puts "#{key}\t#{value}\t#{start_timer+poll_interval}"
      end
    end
    
    if true == critical_state
      print "critical"
      critical
    else
      ok
    end
  end

  def getObject(oName)
    SNMP::Manager.open(:host => "#{config[:host]}", :community => "#{config[:community]}") do |manager|
      response = manager.get(oName)
      response.each_varbind do |vb|
        return  vb.value.to_s
      end
    end
  end

  def getSystemName
    sysName = getObject("sysName.0")
    formatName(sysName)
  end

  def formatName(nameStr)
    values = nameStr.downcase
    #values.join('.')
  end
  
  def recalculateNegatives(key, value)
    abs_value = value.abs
    response = ""
    max = 2_147_483_647
    if config[:host] == "10.99.1.5"
      until response != ""
        response = `curl -s http://localhost:4567/events/sensu-ipmi.moc.ne.edu/switch_network_r3_c17`
      end
    else 
      until response != ""
        response = `curl -s http://localhost:4567/events/sensu-ipmi.moc.ne.edu/switch_network`
      end
    end
    formatted_response = JSON.parse(response)
    output = formatted_response["check"]["output"]
    output.gsub!(/\t/, "\n")
    tokenized_output = output.split("\n")
    lookup = {}
    tokenized_output.each_with_index do |token, index|
      order = index + 1
      lookup[token] = tokenized_output[order].to_f if order % 3 == 1
    end
    prev_value = lookup[key]
    return 0 if prev_value.nil?
    max - prev_value + abs_value
  end


end
