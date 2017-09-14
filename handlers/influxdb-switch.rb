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
    influxdb = InfluxDB::Client.new influxdb_db,
                                   host: influxdb_server,
                                   username: influxdb_user,
                                   password: influxdb_pass,
                                   time_precision: time_precision

    check_name = @event['check']['name']
    if check_name.include? "-"
        check_name = check_name.gsub!'-','_'
    end
    series = 'switch_network'
    data = []
    @event['check']['output'].each_line do |metric|
      m = metric.split
      next unless m.count == 3
      tags = m[0].split(".")
      host = tags[0].to_s
      interface = tags[1].to_s
      metric = tags[2].to_s

      value = m[1].to_i

      record = {
        series: series,
        values: {value:value},
        tags: {host:host, interface:interface, metric: metric, category: "Network", source: "Sensu"},
        timestamp: m[2].to_i
      }
      data.push(record)
   end
   influxdb.write_points(data)

  end
  
end
