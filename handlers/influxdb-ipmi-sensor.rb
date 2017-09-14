#!/usr/bin/env ruby
require 'rubygems'
require 'sensu-handler'
require 'influxdb'
class IpmiSensorToInfluxDB < Sensu::Handler
  def filter; end

  def handle
    puts "hello"
    influxdb_server = settings['influxdb']['host']
    influxdb_port   = settings['influxdb']['port']
    influxdb_user   = settings['influxdb']['username']
    influxdb_pass   = settings['influxdb']['password']
    influxdb_db     = settings['influxdb']['database']
    time_precision = 's'

    influxdb = InfluxDB::Client.new influxdb_db,
                                   host: influxdb_server,
                                   username: influxdb_user,
                                   password: influxdb_pass,
                                   time_precision: time_precision

    check_name = @event['check']['name']
    if check_name.include? "-"
        check_name = check_name.gsub!'-','_'
    end
    series = 'ipmi_sensor_metrics'
    data = []

    @event['check']['output'].each_line do |metric|
      m = metric.split
      puts m
      next unless m.count == 3
      metricInfo = extractHost(m[0])
  
      host = metricInfo["host"]
      tags = metricInfo["tags"]
      sensor = tags[0].to_s
      value = m[1].to_f
      
      record = {
          series: series,
          values: {value:value},
          tags: {host:host, sensor:sensor, category:"Sensor",source:"Sensu"},
          timestamp: m[2].to_i
      }
      data.push(record)
   end
   influxdb.write_points(data)

  end
 
  def extractHost(s)
       t = s
       metricInfo = {}
       host = t.match(/[\w.-]+(.edu|.com)/)
       if(host.to_s)
          metricInfo["host"] = host.to_s
          tags = t.sub(/[\w.-]+(.edu|.com)./,"")
          
          metricInfo["tags"] = tags.split(".")
          return metricInfo
       end
  end
      
end 
