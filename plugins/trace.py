import os
import calendar
from datetime import datetime
import time

#f = open("sensor_data.txt", "w")

def run():
	output = os.popen("ipmitool -I lanplus -U admin -P 73qtx8nVXa4c06 -H 10.99.1.147 -S /etc/sensu/plugins/sdr_dump_file sensor reading FAN1_TACH1 POWER_USAGE P1_TEMP_SENS PCH_TEMP_SENS").read()
        lines = output.splitlines()
        for line in lines:
            print line.split()
	    output = line.split()
            print("compute47.ne.edu "+output[0])
	print (output[0] + " " + output[2] + " " + str(calendar.timegm(datetime.now().timetuple())) + "\n" )
	print (output[0] + " " + output[2] + " " + str(calendar.timegm(datetime.now().timetuple())) + "\n" )
#	print (output[3] + " " + output[5] + " " + str(calendar.timegm(datetime.now().timetuple())) + "\n" )
#	print (output[6] + " " + output[8] + " " + str(calendar.timegm(datetime.now().timetuple())) + "\n" )
#	print (output[9] + " " + output[11] + " " + str(calendar.timegm(datetime.now().timetuple())) + "\n" )
	time.sleep(.5)


run()

#f.close()
