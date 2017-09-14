#! /usr/bin/env ruby
#  encoding: UTF-8
#
#   memory-metrics
#
# DESCRIPTION:
#
# OUTPUT:
#   metric data
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   gem: sensu-plugin
#   gem: socket
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
require 'socket'

class MemoryGraphite < Sensu::Plugin::Metric::CLI::Graphite
  option :scheme,
         description: 'Metric naming scheme, text to prepend to metric',
         short: '-s SCHEME',
         long: '--scheme SCHEME',
         default: "#{Socket.gethostname}.memory"

  option :threshold,
         description: 'Threshold for memory usage percentage',
         short: '-t THESHOLD',
         long: '--threshold THRESHOLD',
         default: "100"


  def run
    # Metrics borrowed from hoardd: https://github.com/coredump/hoardd

    mem = metrics_hash

    mem.each do |k, v|
      output "#{config[:scheme]}.#{k}", v
    end

    ok
  end

  def metrics_hash
    mem = {}
    meminfo_output.each_line do |line|
      mem['total']     = line.split(/\s+/)[1].to_i * 1024 if line.match(/^MemTotal/)
      mem['free']      = line.split(/\s+/)[1].to_i * 1024 if line.match(/^MemFree/)
      mem['buffers']   = line.split(/\s+/)[1].to_i * 1024 if line.match(/^Buffers/)
      mem['cached']    = line.split(/\s+/)[1].to_i * 1024 if line.match(/^Cached/)
      mem['swapTotal'] = line.split(/\s+/)[1].to_i * 1024 if line.match(/^SwapTotal/)
      mem['swapFree']  = line.split(/\s+/)[1].to_i * 1024 if line.match(/^SwapFree/)
      mem['dirty']     = line.split(/\s+/)[1].to_i * 1024 if line.match(/^Dirty/)
    end
    mem['used'] = mem['total'] - mem['free']
    mem['swapUsed'] = mem['swapTotal'] - mem['swapFree']
    mem['usedWOBuffersCaches'] = mem['used'] - (mem['buffers'] + mem['cached'])
    mem['freeWOBuffersCaches'] = mem['free'] + (mem['buffers'] + mem['cached'])
    mem['swapUsedPercentage'] = 100 * mem['swapUsed'] / mem['swapTotal'] if mem['swapTotal'] > 0
    mem['used_without_disk_caching'] = mem['total'] - mem['freeWOBuffersCaches']

    memory_used = (100.0 * mem['used_without_disk_caching']) / mem['total']
     top5 = 'ps -eo user,pid,%mem,command --sort=%mem --cols 75 | tail -10| tac'
     header = 'ps -eo user,pid,%mem,command --sort=%mem| head -n1'
     output = 'ls'
    if config[:threshold].to_f < memory_used
      print "critical\n"
      print "Using ", memory_used, "% Memory\n"
      system header
      system top5
      critical
    end





    mem
  end

  def meminfo_output
    File.open('/proc/meminfo', 'r')
  end
end
