#!/usr/bin/env python
# This check is for see if all of the Sensu checks that have been issued are ok or not
# This uses Sensu's aggregates API 
# For more information
import json
import requests
import sys

aggregate_query = 'http://localhost:4567/aggregates'
agg_res = requests.get(aggregate_query)
aggregates = agg_res.json()

for aggregate in aggregates:
  issued_checks = aggregate['issued']
  name = aggregate['check']
  for check in issued_checks:
    check_query = aggregate_query + "/%(name)s/%(check)s" % locals()
    check_res = requests.get(check_query)
    statuses = check_res.json()
    if statuses['critical'] >= 1:
      print('The %(name)s check is in critical condition' % locals())
      sys.exit(2)
    elif statuses['warning'] >= 1:
      print('The %(name)s check has a warning' % locals())
      sys.exit(1)

# if this check doesn't exit before here then all of the checks have been good for the last 5-10 minutes
print('All of the checks are looking good!')
sys.exit(0)
