#!/usr/bin/env ruby
require 'readline'
class Test
  def run
    
    res= `ipmitool -I lanplus -U  admin -P 73qtx8nVXa4c06 -H 10.99.1.147 -S /etc/sensu/plugins/sdr_dump_file sensor reading FAN1_TACH1 POWER_USAGE P1_TEMP_SENS PCH_TEMP_SENS`
    res.each_line do |line|
      sensor = line.split

      name = sensor[0]
      value = sensor[2]

      print "#{name}", value
    end

  end
end

c = Test.new
c.run
