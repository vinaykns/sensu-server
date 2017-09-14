require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-plugin/metric/cli'
require 'rubyipmi'
require 'socket'
require 'timeout'

class CheckSensor < Sensu::Plugin::Metric::CLI::Graphite
  option :scheme,
       description: 'Metric naming scheme, text to prepend to .$parent.$child',

       long: '--scheme SCHEME',
       default: "#{Socket.gethostname}.ipmisensor"
  
   option :sensor,
        description: 'IPMI sensor to gather stats for.  Default is ALL',
        short: '-s SENSOR_NAME',
        long: '--sensor SENSOR_NAME',
        default: 'all'

   option :username,
       description: 'IPMI Username',
       short: '-u IPMI_USERNAME',
       long: '--username IPMI_USERNAME',
       required: true

  option :password,
       description: 'IPMI Password',
       short: '-p IPMI_PASSWORD',
       long: '--password IPMI_PASSWORD',
       required: true

  option :host,
       description: 'IPMI Hostname or IP',
       short: '-h IPMI_HOST',
       long: '--host IPMI_HOST',
       required: true
  
  option :provider,
       short: '-i IPMI_PROVIDER',
       long: '--ipmitool IPMI_PROVIDER',
       default: 'ipmitool'


  def conn
  timeout(config[:timeout].to_i) do
    Rubyipmi.connect(config[:username],
                     config[:password],
                     config[:host],
		     config[:provider])
    end 
  end

  def run
    #YELLOW
    sensor = conn.sensors.list        
          
        name = sensor[1][:name]
        value = sensor[1][:value] 

          value = Float(value)
          output "#{config[:scheme]}.#{name}", value, Time.now.to_i          
     end
    end        
    
