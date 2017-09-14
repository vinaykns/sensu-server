#!/usr/bin/env ruby
require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-plugin/metric/cli'
require 'snmp'
require 'pry'

#disable kernel warning
#manager.load_module will cause warning messages
$VERBOSE = nil

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

  def run
    
    switchName = getSystemName

    cpmTable_columns = ["cpmCPUTotal1minRev", "cpmCPUMemoryFree","cpmCPUMemoryUsed"]
    outputs = {}
    SNMP::Manager.open(:host => "#{config[:host]}", :community => "#{config[:community]}") do |manager|
       manager.load_module("CISCO-PROCESS-MIB")
     
       manager.walk(cpmTable_columns) do |row|
         cpmTable_columns.each_with_index do |column, index|
           key = [switchName,"#{column}"].join(".")
	    key.gsub!("cpm", "CiscoSwitch")
           outputs[key] = row[index].value
         end
       end
    end
    outputs.each do |key,value|
          output "#{key}","#{value}"
    end
    ok
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
      #values = nameStr.downcase.split('-')
      #values.join('.')
      value = nameStr.downcase
  end
end
