#!/usr/bin/env ruby
require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-plugin/metric/cli'
require 'snmp'

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

    ifTable_columns = ["ifDescr", "ifOperStatus"]
    outputs = {}
    SNMP::Manager.open(:host => "#{config[:host]}", :community => "#{config[:community]}") do |manager|
    manager.walk(ifTable_columns) do |row|
        key = [switchName,row[0].value.downcase,"status"].join(".")
        outputs[key] = row[1].value
    end
        outputs.each do |key,value|
          output "#{key}","#{value}"
        end
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
      values = nameStr.downcase.split('-')
      values.join('.')
  end

end
