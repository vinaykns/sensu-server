#!/usr/bin/python2

import subprocess
import time
from datetime import datetime, timedelta
import shlex
from influxdb import InfluxDBClient
import pdb

'''
ip_addresses = ['10.99.1.126','10.99.1.117','10.99.1.128','10.99.1.129','10.99.1.130','10.99.1.131','10.99.1.132','10.99.1.133','10.99.1.134','10.99.1.135','10.99.1.136','10.99.1.137','10.99.1.138','10.99.1.139',
                '10.99.1.140','10.99.1.141','10.99.1.142','10.99.1.143','10.99.1.144','10.99.1.146','10.99.1.147','10.99.1.148','10.99.1.104','10.99.1.125','10.99.1.145','10.99.1.105','10.99.1.107','10.99.1.108',
                '10.99.1.103','10.99.1.147','10.99.1.118','10.99.1.120','10.99.1.121','10.99.1.123','10.99.1.124','10.99.1.109','10.99.1.106','10.99.1.102']
'''
'''
compute_hosts = ["compute-1.moc.ne.edu","compute-10.moc.ne.edu","compute-11.moc.ne.edu","compute-12.moc.ne.edu","compute-13.moc.ne.edu","compute-14.moc.ne.edu","compute-15.moc.ne.edu","compute-16.moc.ne.edu","compute-17.moc.ne.edu","compute-18.moc.ne.edu","compute-19.moc.ne.edu","compute-2.moc.ne.edu","compute-20.moc.ne.edu","compute-21.moc.ne.edu","compute-22.moc.ne.edu","compute-23.moc.ne.edu","compute-24.moc.ne.edu","compute-25.moc.ne.edu",
"compute-26.moc.ne.edu","compute-27.moc.ne.edu","compute-28.moc.ne.edu","compute-29.moc.ne.edu","compute-3.moc.ne.edu","compute-30.moc.ne.edu","compute-31.moc.ne.edu","compute-32.moc.ne.edu","compute-33.moc.ne.edu",
"compute-34.moc.ne.edu","compute-35.moc.ne.edu","compute-36.moc.ne.edu","compute-37.moc.ne.edu","compute-38.moc.ne.edu","compute-39.moc.ne.edu","compute-4.moc.ne.edu","compute-40.moc.ne.edu","compute-41.moc.ne.edu",
"compute-42.moc.ne.edu","compute-43.moc.ne.edu","compute-44.moc.ne.edu","compute-45.moc.ne.edu","compute-46.moc.ne.edu","compute-47.moc.ne.edu","compute-5.moc.ne.edu","compute-6.moc.ne.edu","compute-7.moc.ne.edu","compute-8.moc.ne.edu","compute-9.moc.ne.edu"]
'''
#output = {}
'''
for address in ip_addresses:
  exec_cmd = 'ipmitool -I lanplus -U admin -P 73qtx8nVXa4c06 -H {} -S /etc/sensu/plugins/sdr_dump_file sensor reading FAN1_TACH1 FAN1_TACH2 FAN2_TACH1 FAN2_TACH2 FAN3_TACH1'.format(address)
  process = subprocess.Popen(shlex.split(exec_cmd), stdout = subprocess.PIPE, stderr = subprocess.PIPE)
  start = datetime.now()
  while datetime.now() - start < timedelta(seconds=1):
      pdb.set_trace()  
      out,err = process.communicate()

 
  errcode = process.returncode
  time = datetime.now().strftime('%H:%M:%S %Y-%m-%d')
  output = {}
  if errcode == 0:
    output['timestamp'] = time
    output['level'] = "info"
    output['output'] = out
  elif errcode != 0:
    output['timestamp'] = time
    output['level'] = "Error"
    output['output'] = out
  '''
compute_hosts = ["compute-26.moc.ne.edu","compute-27.moc.ne.edu","compute-17.moc.ne.edu", "compute-28.moc.ne.edu", "compute-29.moc.ne.edu", "compute-30.moc.ne.edu","compute-31.moc.ne.edu","compute-32.moc.ne.edu",
"compute-33.moc.ne.edu","compute-34.moc.ne.edu","compute-35.moc.ne.edu", "compute-36.moc.ne.edu", "compute-37.moc.ne.edu","compute-38.moc.ne.edu","compute-39.moc.ne.edu","compute-40.moc.ne.edu","compute-41.moc.ne.edu","compute-42.moc.ne.edu","compute-43.moc.ne.edu", "compute-44.moc.ne.edu", "compute-46.moc.ne.edu", "compute-47.moc.ne.edu", "compute-48.moc.ne.edu",
"compute-4.moc.ne.edu", "compute-25.moc.ne.edu", "compute-45.moc.ne.edu", "compute-5.moc.ne.edu", "compute-7.moc.ne.edu", "compute-8.moc.ne.edu", "compute-3.moc.ne.edu", "compute-47.moc.ne.edu",
"compute-47.moc.ne.edu", "compute-18.moc.ne.edu", "compute-20.moc.ne.edu", "compute-21.moc.ne.edu", "compute-23.moc.ne.edu","compute-24.moc.ne.edu", "compute-9.moc.ne.edu", "compute-6.moc.ne.edu",
"compute-2.moc.ne.edu"]


client = InfluxDBClient('10.13.37.179', 8086, 'root', 'root','sensu_db')

temp_date = datetime.utcnow()
start_date = datetime.utcnow() - timedelta(minutes=10)
start_date_conv = start_date.strftime('%Y-%m-%d %H:%M')
start = str(start_date_conv).replace(" ","T")+":00Z"
end_date = start_date + timedelta(minutes=1)
end_date_conv = end_date.strftime('%Y-%m-%d %H:%M')
end = str(end_date_conv).replace(" ","T")+":00Z"
for host in compute_hosts:
  try:
    pdb.set_trace()
    result=client.query("select * from ipmi_sensor_metrics where time >= '" + start + "' and time <='" + end + "' and host = '" + host + "';")
    print result
  except:
    print "No results for host"
     



