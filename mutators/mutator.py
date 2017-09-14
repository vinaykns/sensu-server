#!/usr/bin/env python
with open('/etc/sensu/plugins/mutated.txt','r') as f:

        line=f.read().replace('[','').replace(']','').replace('\"','').split(',')
	
	if "19" in line[2]:
		print "Switch 2: 10.99.1.6"
	else:
		print "Switch 1: 10.99.1.5"
	
	print ("\nUnusual \n")
	while line!=[]:
                if "ethernet1" in line[3]:
			speed = float(line[1])/1024
                        print line[0],'\t',"%.2f" % speed,"kb/s",'\t',line[2],'\t',line[3]
                line=line[4:]

print ("Normal\n")

with open('etc/sensu/plugins/normal.txt','r') as f:
	line=f.read().replace('[','').replace(']','').replace('\"','').split(',')
	while line!=[]:
		if "ethernet1" in line[3]:
                        speed = float(line[1])/1024
			print line[0],'\t',"%.2f" % speed,"kb/s",'\t',line[2],'\t',line[3]
        	line=line[4:]

