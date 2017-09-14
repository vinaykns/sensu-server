#!/usr/bin/env ruby

require 'rubygems'
require 'sensu-handler'
require 'influxdb'
class SensuToInfluxDB < Sensu::Handler
  def filter; end

  def handle
    influxdb_server = settings['influxdb']['host']
    influxdb_port   = settings['influxdb']['port']
    influxdb_user   = settings['influxdb']['username']
    influxdb_pass   = settings['influxdb']['password']
    influxdb_db     = settings['influxdb']['database']
    time_precision = 's'
    puts "goodbye"
    puts influxdb_server
    influxdb = InfluxDB::Client.new influxdb_db,
                                   host: influxdb_server,
                                   username: influxdb_user,
                                   password: influxdb_pass,
                                   time_precision: time_precision

    check_name = @event['check']['name']
    if check_name.include? "-"
        check_name = check_name.gsub!'-','_'
    end
    series = check_name
    data = []
    @event['check']['output'].each_line do |metric|
      m = metric.split
      puts m
      next unless m.count == 3
      metricInfo = extractHost(m[0])
  
      host = metricInfo["host"]
      host1 = @event['client']['name']
      tags = metricInfo["tags"]
      metric = tags[-1].to_s
      value = m[1].to_i
      

      record = {
        series: series,
        values: {value:value},
        tags: {host:host1, metric: metric},
        timestamp: m[2].to_i
      }
      data.push(record)
   end
   influxdb.write_points(data)

  end
  
  #extract host name from the line
  def extractHost(s)
       t = s
       metricInfo = {}
       host = t.match(/[\w.-]+(.edu|.com)/)
       if(host.to_s)
          metricInfo["host"] = host.to_s
          tags = t.sub(/[\w.-]+(.edu|.com)./,"")
          #
          metricInfo["tags"] = tags.split(".")
          return metricInfo
       end
  end
      
end
