#!/usr/bin/env ruby

require 'rubygems'
require 'sensu-handler'
require 'influxdb'
class SensuToInfluxDB < Sensu::Handler
  def filter; end

  def handle
    free = -1
    used = -1
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
    series = check_name
    data = []
    @event['check']['output'].each_line do |metric|
      m = metric.split
      next unless m.count == 3
      tags = m[0].split(".")
      host = tags[0].to_s
      metric = tags[1].to_s
      value = m[1].to_i
      if metric == 'CiscoSwitchCPUMemoryFree'
        free = value
      end
      if metric == 'CiscoSwitchCPUMemoryUsed'
        used = value
      end
      if free != -1 and used != -1
        used_percentage = 100*(used.to_f / (used+free))
        record = {
          series: series,
          values: {value:used_percentage},
          tags: {host:host, metric: "CiscoSwitchCPUUsed_Percentage", source: "Sensu", category:"Memory"},
          timestamp: m[2].to_i
        }
        data.push(record)
        avail = -1
        used = -1
      end

      record = {
        series: series,
        values: {value:value},
        tags: {host:host, metric: metric, category: "Memory", source: "Sensu"},
        timestamp: m[2].to_i
      }
      data.push(record)
   end
   influxdb.write_points(data)

  end
  
end
