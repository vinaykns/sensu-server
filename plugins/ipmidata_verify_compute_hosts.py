#!/usr/bin/python2

import subprocess
import time
from datetime import datetime, timedelta
import shlex
import smtplib
from email.mime.text import MIMEText

ip_addresses = ['10.99.1.126','10.99.1.117','10.99.1.128','10.99.1.129','10.99.1.130','10.99.1.131','10.99.1.132','10.99.1.133','10.99.1.134','10.99.1.135','10.99.1.136','10.99.1.137','10.99.1.138','10.99.1.139',
                '10.99.1.140','10.99.1.141','10.99.1.142','10.99.1.143','10.99.1.144','10.99.1.146','10.99.1.147','10.99.1.148','10.99.1.104','10.99.1.125','10.99.1.145','10.99.1.105','10.99.1.107','10.99.1.108',
                '10.99.1.103','10.99.1.147','10.99.1.118','10.99.1.120','10.99.1.121','10.99.1.123','10.99.1.124','10.99.1.109','10.99.1.106','10.99.1.102']


#ip_addresses = ['10.99.1.126','192.168.100.26']

#output = {}

for address in ip_addresses:
  exec_cmd = 'ipmitool -I lanplus -U admin -P 73qtx8nVXa4c06 -H {} -S /etc/sensu/plugins/sdr_dump_file sensor reading FAN1_TACH1 FAN1_TACH2 FAN2_TACH1 FAN2_TACH2 FAN3_TACH1'.format(address)
  process = subprocess.Popen(shlex.split(exec_cmd), stdout = subprocess.PIPE, stderr = subprocess.PIPE)
  out,err = process.communicate()
  ret = process.returncode
  if(err):
    msg = MIMEText("Unable to get ipmi data from " + address)
    msg['Subject'] = 'IPMI Data Missing'
    msg['From'] = 'sensu@sensu-ipmi'
    msg['To'] = 'kapalavai.n@husky.neu.edu'
    s = smtplib.SMTP('localhost')
    s.sendmail('sensu@sensu-ipmi',['kapalavai.n@husky.neu.edu'], msg.as_string())
    s.quit()
 
