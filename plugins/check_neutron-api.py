#!/usr/bin/env python
import sys
import argparse
from keystoneclient.v2_0 import client as keystone_client
from keystoneclient import session
from keystoneclient.auth.identity import v2
import logging
import urllib2
from neutronclient.neutron import client as neutron_client

STATE_OK = 0
STATE_WARNING = 1
STATE_CRITICAL = 2
STATE_UNKNOWN = 3

parser = argparse.ArgumentParser(description='Check OpenStack Neutron agent status')
parser.add_argument('--auth-url', metavar='URL', type=str,
                    required=True,
                    help='Keystone URL')
parser.add_argument('--username', metavar='username', type=str,
                    required=True,
                    help='username for authentication')
parser.add_argument('--password', metavar='password', type=str,
                    required=True,
                    help='password for authentication')
parser.add_argument('--tenant', metavar='tenant', type=str,
                    required=True,
                    help='tenant name for authentication')
args = parser.parse_args()

try:
	neutron = neutron_client.Client('2.0',
		auth_url=args.auth_url,
		username=args.username,
		password=args.password,
		tenant_name=args.tenant,
		endpoint_type="internalURL")

	networks = neutron.list_networks()
except Exception as e:
    print str(e)
    sys.exit(STATE_CRITICAL)

if len(networks) < 1:
     exit_state = STATE_WARNING
     state_string = "WARNING"
else:
     exit_state = STATE_OK
     state_string = "OK"
     
print "Neutron API status: {state_str}, {networks} network(s) found.".format(state_str=state_string, networks=len(networks))
sys.exit(exit_state)

