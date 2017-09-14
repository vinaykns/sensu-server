import os


text = """{\"
  \"checks\":{
    \"sensor_check\":{
      \"handlers\": [\"default\",\"influxdb\"],
      \"type\": \"metric\",
      \"command\": \"/etc/sensu/plugins/check-sensor-t.rb -u admin -p 73qtx8nVXa4c06 -h 10.99.1.101\",
      \"interval\": 30,
      \"subscribers\": [ \"moc-impi\" ]
     }
  }\" """


for x in range(102,149):
	text.replace(str(x-1), str(x))
	cmdstring = "echo %s > check-sensor-%s.json" % (text, str(x))
	os.system(cmdstring)
